(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-bounty (err u102))
(define-constant err-already-claimed (err u103))
(define-constant err-not-claimed (err u104))
(define-constant err-insufficient-funds (err u105))
(define-constant err-unauthorized (err u106))
(define-constant err-expired (err u107))
(define-constant err-not-expired (err u108))

(define-data-var bounty-id-nonce uint u0)
(define-data-var total-bounties uint u0)
(define-data-var total-rewards-distributed uint u0)

(define-map bounties
  { bounty-id: uint }
  {
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    reward-amount: uint,
    evidence-required: (string-ascii 200),
    expiry-block: uint,
    status: (string-ascii 20),
    claimer: (optional principal),
    evidence-hash: (optional (string-ascii 64)),
    created-at: uint,
  }
)

(define-map user-bounties
  { user: principal }
  {
    created-count: uint,
    claimed-count: uint,
    total-earned: uint,
  }
)

(define-map verifiers
  { verifier: principal }
  {
    is-active: bool,
    reputation: uint,
  }
)

(define-map bounty-verifications
  {
    bounty-id: uint,
    verifier: principal,
  }
  {
    approved: bool,
    timestamp: uint,
  }
)

(define-public (create-bounty
    (title (string-ascii 100))
    (description (string-ascii 500))
    (evidence-required (string-ascii 200))
    (duration-blocks uint)
  )
  (let (
      (bounty-id (+ (var-get bounty-id-nonce) u1))
      (reward-amount (stx-get-balance tx-sender))
      (expiry-block (+ stacks-block-height duration-blocks))
    )
    (asserts! (> reward-amount u0) err-insufficient-funds)
    (asserts! (> duration-blocks u0) err-invalid-bounty)
    (asserts! (> (len title) u0) err-invalid-bounty)
    (try! (stx-transfer? reward-amount tx-sender (as-contract tx-sender)))
    (map-set bounties { bounty-id: bounty-id } {
      creator: tx-sender,
      title: title,
      description: description,
      reward-amount: reward-amount,
      evidence-required: evidence-required,
      expiry-block: expiry-block,
      status: "open",
      claimer: none,
      evidence-hash: none,
      created-at: stacks-block-height,
    })
    (map-set user-bounties { user: tx-sender }
      (merge
        (default-to {
          created-count: u0,
          claimed-count: u0,
          total-earned: u0,
        }
          (map-get? user-bounties { user: tx-sender })
        ) { created-count: (+
        (get created-count
          (default-to {
            created-count: u0,
            claimed-count: u0,
            total-earned: u0,
          }
            (map-get? user-bounties { user: tx-sender })
          ))
        u1
      ) }
      ))
    (var-set bounty-id-nonce bounty-id)
    (var-set total-bounties (+ (var-get total-bounties) u1))
    (ok bounty-id)
  )
)

(define-public (claim-bounty
    (bounty-id uint)
    (evidence-hash (string-ascii 64))
  )
  (let ((bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) err-not-found)))
    (asserts! (is-eq (get status bounty) "open") err-already-claimed)
    (asserts! (< stacks-block-height (get expiry-block bounty)) err-expired)
    (asserts! (> (len evidence-hash) u0) err-invalid-bounty)
    (map-set bounties { bounty-id: bounty-id }
      (merge bounty {
        status: "claimed",
        claimer: (some tx-sender),
        evidence-hash: (some evidence-hash),
      })
    )
    (ok true)
  )
)

(define-public (verify-bounty
    (bounty-id uint)
    (approved bool)
  )
  (let (
      (bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) err-not-found))
      (verifier-info (unwrap! (map-get? verifiers { verifier: tx-sender }) err-unauthorized))
    )
    (asserts! (get is-active verifier-info) err-unauthorized)
    (asserts! (is-eq (get status bounty) "claimed") err-not-claimed)
    (map-set bounty-verifications {
      bounty-id: bounty-id,
      verifier: tx-sender,
    } {
      approved: approved,
      timestamp: stacks-block-height,
    })
    (if approved
      (begin
        (map-set bounties { bounty-id: bounty-id }
          (merge bounty { status: "verified" })
        )
        (try! (distribute-reward bounty-id))
      )
      (map-set bounties { bounty-id: bounty-id }
        (merge bounty {
          status: "rejected",
          claimer: none,
          evidence-hash: none,
        })
      )
    )
    (ok approved)
  )
)

(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set verifiers { verifier: verifier } {
      is-active: true,
      reputation: u0,
    })
    (ok true)
  )
)

(define-public (remove-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set verifiers { verifier: verifier }
      (merge
        (default-to {
          is-active: false,
          reputation: u0,
        }
          (map-get? verifiers { verifier: verifier })
        ) { is-active: false }
      ))
    (ok true)
  )
)

(define-public (cancel-bounty (bounty-id uint))
  (let ((bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get creator bounty)) err-unauthorized)
    (asserts!
      (or
        (is-eq (get status bounty) "open")
        (> stacks-block-height (get expiry-block bounty))
      )
      err-invalid-bounty
    )
    (try! (as-contract (stx-transfer? (get reward-amount bounty) tx-sender (get creator bounty))))
    (map-set bounties { bounty-id: bounty-id }
      (merge bounty { status: "cancelled" })
    )
    (ok true)
  )
)

(define-private (distribute-reward (bounty-id uint))
  (let (
      (bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) err-not-found))
      (claimer (unwrap! (get claimer bounty) err-not-found))
      (reward-amount (get reward-amount bounty))
    )
    (try! (as-contract (stx-transfer? reward-amount tx-sender claimer)))
    (map-set user-bounties { user: claimer }
      (merge
        (default-to {
          created-count: u0,
          claimed-count: u0,
          total-earned: u0,
        }
          (map-get? user-bounties { user: claimer })
        ) {
        claimed-count: (+
          (get claimed-count
            (default-to {
              created-count: u0,
              claimed-count: u0,
              total-earned: u0,
            }
              (map-get? user-bounties { user: claimer })
            ))
          u1
        ),
        total-earned: (+
          (get total-earned
            (default-to {
              created-count: u0,
              claimed-count: u0,
              total-earned: u0,
            }
              (map-get? user-bounties { user: claimer })
            ))
          reward-amount
        ),
      })
    )
    (var-set total-rewards-distributed
      (+ (var-get total-rewards-distributed) reward-amount)
    )
    (ok true)
  )
)

(define-read-only (get-bounty (bounty-id uint))
  (map-get? bounties { bounty-id: bounty-id })
)

(define-read-only (get-user-stats (user principal))
  (default-to {
    created-count: u0,
    claimed-count: u0,
    total-earned: u0,
  }
    (map-get? user-bounties { user: user })
  )
)

(define-read-only (get-verifier-status (verifier principal))
  (default-to {
    is-active: false,
    reputation: u0,
  }
    (map-get? verifiers { verifier: verifier })
  )
)

(define-read-only (get-bounty-verification
    (bounty-id uint)
    (verifier principal)
  )
  (map-get? bounty-verifications {
    bounty-id: bounty-id,
    verifier: verifier,
  })
)

(define-read-only (get-contract-stats)
  {
    total-bounties: (var-get total-bounties),
    total-rewards-distributed: (var-get total-rewards-distributed),
    current-bounty-id: (var-get bounty-id-nonce),
  }
)

(define-read-only (is-bounty-expired (bounty-id uint))
  (match (map-get? bounties { bounty-id: bounty-id })
    bounty (> stacks-block-height (get expiry-block bounty))
    false
  )
)

(define-read-only (get-active-bounties-count)
  (var-get total-bounties)
)
