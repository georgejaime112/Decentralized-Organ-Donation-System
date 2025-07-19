;; Compatibility Matching Contract
;; Identifies suitable organ recipients based on medical compatibility

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-RECIPIENT-NOT-FOUND (err u201))
(define-constant ERR-INVALID-INPUT (err u202))
(define-constant ERR-NO-MATCHES-FOUND (err u203))

;; Data Variables
(define-data-var next-recipient-id uint u1)
(define-data-var next-match-id uint u1)

;; Data Maps
(define-map recipients
  { recipient-id: uint }
  {
    principal: principal,
    name: (string-ascii 100),
    age: uint,
    blood-type: (string-ascii 3),
    organ-needed: (string-ascii 20),
    urgency-level: uint,
    registration-date: uint,
    is-active: bool,
    compatibility-requirements: (string-ascii 200)
  }
)

(define-map recipient-by-principal
  { principal: principal }
  { recipient-id: uint }
)

(define-map compatibility-matches
  { match-id: uint }
  {
    donor-id: uint,
    recipient-id: uint,
    compatibility-score: uint,
    match-date: uint,
    status: (string-ascii 20)
  }
)

(define-map blood-compatibility
  { donor-type: (string-ascii 3), recipient-type: (string-ascii 3) }
  { compatible: bool }
)

;; Initialize blood compatibility matrix
(map-set blood-compatibility { donor-type: "O-", recipient-type: "O-" } { compatible: true })
(map-set blood-compatibility { donor-type: "O-", recipient-type: "O+" } { compatible: true })
(map-set blood-compatibility { donor-type: "O-", recipient-type: "A-" } { compatible: true })
(map-set blood-compatibility { donor-type: "O-", recipient-type: "A+" } { compatible: true })
(map-set blood-compatibility { donor-type: "O-", recipient-type: "B-" } { compatible: true })
(map-set blood-compatibility { donor-type: "O-", recipient-type: "B+" } { compatible: true })
(map-set blood-compatibility { donor-type: "O-", recipient-type: "AB-" } { compatible: true })
(map-set blood-compatibility { donor-type: "O-", recipient-type: "AB+" } { compatible: true })

(map-set blood-compatibility { donor-type: "O+", recipient-type: "O+" } { compatible: true })
(map-set blood-compatibility { donor-type: "O+", recipient-type: "A+" } { compatible: true })
(map-set blood-compatibility { donor-type: "O+", recipient-type: "B+" } { compatible: true })
(map-set blood-compatibility { donor-type: "O+", recipient-type: "AB+" } { compatible: true })

;; Read-only functions
(define-read-only (get-recipient (recipient-id uint))
  (map-get? recipients { recipient-id: recipient-id })
)

(define-read-only (get-recipient-by-principal (recipient-principal principal))
  (match (map-get? recipient-by-principal { principal: recipient-principal })
    recipient-info (get-recipient (get recipient-id recipient-info))
    none
  )
)

(define-read-only (get-match (match-id uint))
  (map-get? compatibility-matches { match-id: match-id })
)

(define-read-only (check-blood-compatibility (donor-type (string-ascii 3)) (recipient-type (string-ascii 3)))
  (default-to { compatible: false }
    (map-get? blood-compatibility { donor-type: donor-type, recipient-type: recipient-type })
  )
)

(define-read-only (calculate-compatibility-score
  (donor-age uint)
  (recipient-age uint)
  (blood-compatible bool)
  (urgency-level uint)
)
  (let ((age-diff (if (>= donor-age recipient-age)
                     (- donor-age recipient-age)
                     (- recipient-age donor-age))))
    (+ (if blood-compatible u50 u0)
       (if (<= age-diff u10) u30 (if (<= age-diff u20) u20 u10))
       (* urgency-level u5))
  )
)

;; Public functions
(define-public (register-recipient
  (name (string-ascii 100))
  (age uint)
  (blood-type (string-ascii 3))
  (organ-needed (string-ascii 20))
  (urgency-level uint)
  (compatibility-requirements (string-ascii 200))
)
  (let ((recipient-id (var-get next-recipient-id)))
    (asserts! (> age u0) ERR-INVALID-INPUT)
    (asserts! (< age u100) ERR-INVALID-INPUT)
    (asserts! (<= urgency-level u10) ERR-INVALID-INPUT)

    (map-set recipients
      { recipient-id: recipient-id }
      {
        principal: tx-sender,
        name: name,
        age: age,
        blood-type: blood-type,
        organ-needed: organ-needed,
        urgency-level: urgency-level,
        registration-date: block-height,
        is-active: true,
        compatibility-requirements: compatibility-requirements
      }
    )

    (map-set recipient-by-principal
      { principal: tx-sender }
      { recipient-id: recipient-id }
    )

    (var-set next-recipient-id (+ recipient-id u1))
    (ok recipient-id)
  )
)

(define-public (create-compatibility-match
  (donor-id uint)
  (recipient-id uint)
  (donor-blood-type (string-ascii 3))
  (recipient-blood-type (string-ascii 3))
  (donor-age uint)
  (recipient-age uint)
  (urgency-level uint)
)
  (let ((match-id (var-get next-match-id))
        (blood-compatible (get compatible (check-blood-compatibility donor-blood-type recipient-blood-type)))
        (compatibility-score (calculate-compatibility-score donor-age recipient-age blood-compatible urgency-level)))

    (asserts! (> compatibility-score u30) ERR-INVALID-INPUT)

    (map-set compatibility-matches
      { match-id: match-id }
      {
        donor-id: donor-id,
        recipient-id: recipient-id,
        compatibility-score: compatibility-score,
        match-date: block-height,
        status: "pending"
      }
    )

    (var-set next-match-id (+ match-id u1))
    (ok match-id)
  )
)

(define-public (update-match-status (match-id uint) (new-status (string-ascii 20)))
  (let ((match-info (unwrap! (get-match match-id) ERR-RECIPIENT-NOT-FOUND)))
    (map-set compatibility-matches
      { match-id: match-id }
      (merge match-info { status: new-status })
    )
    (ok true)
  )
)
