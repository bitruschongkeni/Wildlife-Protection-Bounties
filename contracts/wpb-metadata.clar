(define-constant contract-name "Wildlife Protection Bounties")
(define-constant contract-version "1.0.0")
(define-constant contract-description "On-chain bounties for wildlife protection")
(define-constant contract-homepage "https://github.com/Wildlife-Protection-Bounties")

(define-read-only (get-name)
  contract-name)

(define-read-only (get-version)
  contract-version)

(define-read-only (get-description)
  contract-description)

(define-read-only (get-homepage)
  contract-homepage)

(define-read-only (get-contract-principal)
  (as-contract tx-sender))

(define-read-only (get-metadata)
  {
    name: contract-name,
    version: contract-version,
    description: contract-description,
    homepage: contract-homepage,
  })