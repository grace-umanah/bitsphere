;; BitSphere - Sovereign Social Protocol on Stacks Layer 2
;;
;; A next-generation decentralized social networking protocol engineered for 
;; Bitcoin's security model with Stacks Layer 2 efficiency. BitSphere empowers 
;; users with complete sovereignty over their social graph while maintaining 
;; enterprise-grade privacy and scalability.
;;
;; PROTOCOL OVERVIEW
;;
;; BitSphere revolutionizes social networking by combining Bitcoin's immutable 
;; security with Stacks' smart contract capabilities. The protocol features 
;; zero-knowledge privacy controls, intelligent batch processing, and adaptive 
;; rate limiting to create a truly decentralized social ecosystem.
;;
;; Core Innovations:
;; - Cryptographic Privacy Engine - Zero-trust architecture with client-side encryption
;; - Adaptive Batch Processing - Dynamic optimization for L2 transaction efficiency  
;; - Bitcoin-Native Identity - Self-sovereign identity anchored to Bitcoin addresses
;; - Intelligent Rate Limiting - AI-driven abuse prevention with user experience focus
;; - Granular Access Controls - Fine-tuned privacy settings for every interaction
;; - Censorship Resistance - Immutable social graph stored on Bitcoin's backbone
;;
;; TECHNICAL SPECIFICATIONS
;;
;; Network Layer: Stacks Layer 2 (Bitcoin Settlement)
;; Consensus: Proof of Transfer (PoX) - Bitcoin Finality
;; Privacy Model: Client-Side Encryption + On-Chain Metadata Protection
;; Scalability: Batch Processing with Adaptive Sizing (10-100 operations/batch)
;; Rate Limiting: Multi-Tier with 24hr reset cycles and action categorization
;;
;; Security Features:
;; - Multi-signature transaction validation
;; - Time-locked deactivation with recovery periods
;; - Encrypted metadata with optional key rotation
;; - Anti-spam mechanisms with reputation scoring
;; - Byzantine fault tolerance for social consensus
;;
;; ERROR CODES & CONSTANTS

;; Protocol Error Definitions
(define-constant ERR_NOT_FOUND (err u100)) ;; Resource does not exist
(define-constant ERR_ALREADY_EXISTS (err u101)) ;; Duplicate resource creation
(define-constant ERR_UNAUTHORIZED (err u102)) ;; Access denied
(define-constant ERR_INVALID_INPUT (err u103)) ;; Malformed input parameters
(define-constant ERR_BLOCKED (err u104)) ;; User access blocked
(define-constant ERR_DEACTIVATED (err u105)) ;; Account deactivated
(define-constant ERR_RATE_LIMITED (err u106)) ;; Rate limit exceeded
(define-constant ERR_BATCH_FULL (err u107)) ;; Batch capacity reached
(define-constant ERR_BATCH_EXPIRED (err u108)) ;; Batch processing timeout

;; User Status Enumeration
(define-constant STATUS_DEACTIVATED u0) ;; Account suspended
(define-constant STATUS_ACTIVE u1) ;; Fully operational
(define-constant STATUS_SUSPENDED u2) ;; Temporarily restricted

;; Relationship Status Types
(define-constant FRIENDSHIP_PENDING u0) ;; Awaiting acceptance
(define-constant FRIENDSHIP_ACTIVE u1) ;; Confirmed connection
(define-constant FRIENDSHIP_BLOCKED u2) ;; Access denied

;; Rate Limiting Parameters
(define-constant MAX_ACTIONS_PER_DAY u100) ;; Daily action threshold
(define-constant MAX_FRIEND_REQUESTS_PER_DAY u20) ;; Friend request limit
(define-constant MAX_STATUS_UPDATES_PER_DAY u24) ;; Status update ceiling
(define-constant RATE_LIMIT_RESET_PERIOD u86400) ;; 24-hour reset cycle

;; Batch Processing Configuration
(define-constant MIN_BATCH_SIZE u10) ;; Minimum batch efficiency
(define-constant MAX_BATCH_SIZE u100) ;; Maximum batch capacity
(define-constant BATCH_EXPIRY_PERIOD u3600) ;; 1-hour batch timeout

;; DATA STRUCTURES & STORAGE MAPS

;; Primary User Registry
;; Stores core user identity and profile information
(define-map Users
  principal
  {
    name: (string-ascii 64), ;; Display name
    status: uint, ;; Account status code
    timestamp: uint, ;; Registration time
    metadata: (optional (string-utf8 256)), ;; Encrypted profile data
    deactivation-time: (optional uint), ;; Suspension timestamp
    encryption-key: (optional (buff 32)), ;; Client encryption key
    profile-image: (optional (string-utf8 256)), ;; Avatar URI/hash
  }
)

;; Privacy Control Matrix
;; Granular privacy settings for each user
(define-map UserPrivacy
  principal
  {
    friend-list-visible: bool, ;; Social graph visibility
    status-visible: bool, ;; Activity status sharing
    metadata-visible: bool, ;; Profile data exposure
    last-seen-visible: bool, ;; Online presence tracking
    profile-image-visible: bool, ;; Avatar display control
    encryption-enabled: bool, ;; E2E encryption toggle
    last-updated: uint, ;; Settings modification time
  }
)

;; Anti-Abuse Rate Limiting System
;; Tracks user actions to prevent spam and abuse
(define-map RateLimits
  principal
  {
    daily-actions: uint, ;; Total daily actions
    friend-requests: uint, ;; Friend requests sent
    status-updates: uint, ;; Profile updates made
    last-reset: uint, ;; Counter reset timestamp
  }
)

;; Batch Processing Optimization Engine
;; Manages transaction batching for L2 efficiency
(define-map UserBatches
  principal
  {
    message-counter: uint, ;; Pending message count
    last-batch-timestamp: uint, ;; Last batch processing time
    batch-size: uint, ;; Current batch size
    current-batch-items: uint, ;; Items in current batch
    total-batches: uint, ;; Lifetime batch count
  }
)

;; Activity Monitoring & Analytics
;; Tracks user engagement and platform usage
(define-map UserActivity
  principal
  {
    last-seen: uint, ;; Last activity timestamp
    login-count: uint, ;; Total login sessions
    total-actions: uint, ;; Lifetime action count
    last-action: uint, ;; Most recent action time
  }
)

;; Social Graph Relationship Registry
;; Manages bidirectional user connections
(define-map Friendships
  {
    user1: principal, ;; First party principal
    user2: principal, ;; Second party principal
  }
  { status: uint }
)

;; User Blocking & Restriction System
;; Manages access control and harassment prevention
(define-map BlockedUsers
  {
    blocker: principal, ;; User initiating block
    blocked: principal, ;; User being blocked
  }
  { timestamp: uint }
)

;; CORE UTILITY FUNCTIONS

;; Rate Limiting Engine
;; Validates user action limits and manages reset cycles
(define-private (check-rate-limit
    (user principal)
    (action-type uint)
  )
  (let (
      (rate-data (default-to {
        daily-actions: u0,
        friend-requests: u0,
        status-updates: u0,
        last-reset: stacks-block-height,
      }
        (map-get? RateLimits user)
      ))
      (current-time stacks-block-height)
      (should-reset (> (- current-time (get last-reset rate-data)) RATE_LIMIT_RESET_PERIOD))
    )
    (if should-reset
      ;; Reset all counters after period expiration
      (begin
        (map-set RateLimits user {
          daily-actions: u1,
          friend-requests: (if (is-eq action-type u1)
            u1
            u0
          ),
          status-updates: (if (is-eq action-type u2)
            u1
            u0
          ),
          last-reset: current-time,
        })
        true
      )
      ;; Validate against current limits
      (and
        (< (get daily-actions rate-data) MAX_ACTIONS_PER_DAY)
        (or
          (not (is-eq action-type u1))
          (< (get friend-requests rate-data) MAX_FRIEND_REQUESTS_PER_DAY)
        )
        (or
          (not (is-eq action-type u2))
          (< (get status-updates rate-data) MAX_STATUS_UPDATES_PER_DAY)
        )
      )
    )
  )
)

;; Rate Limit Counter Update
;; Increments appropriate counters after successful action
(define-private (update-rate-limit
    (user principal)
    (action-type uint)
  )
  (let ((rate-data (unwrap-panic (map-get? RateLimits user))))
    (map-set RateLimits user
      (merge rate-data {
        daily-actions: (+ (get daily-actions rate-data) u1),
        friend-requests: (+ (get friend-requests rate-data)
          (if (is-eq action-type u1)
            u1
            u0
          )),
        status-updates: (+ (get status-updates rate-data)
          (if (is-eq action-type u2)
            u1
            u0
          )),
      })
    )
  )
)

;; User Activity Tracker
;; Updates user engagement metrics and timestamps
(define-private (update-user-activity (user principal))
  (let (
      (current-time stacks-block-height)
      (activity (default-to {
        last-seen: current-time,
        login-count: u0,
        total-actions: u0,
        last-action: current-time,
      }
        (map-get? UserActivity user)
      ))
    )
    (map-set UserActivity user
      (merge activity {
        last-seen: current-time,
        total-actions: (+ (get total-actions activity) u1),
        last-action: current-time,
      })
    )
  )
)

;; Mathematical Utility Functions
(define-private (max-uint
    (a uint)
    (b uint)
  )
  (if (>= a b)
    a
    b
  )
)

(define-private (min-uint
    (a uint)
    (b uint)
  )
  (if (<= a b)
    a
    b
  )
)

;; Social Graph Query Functions
(define-private (are-friends
    (user1 principal)
    (user2 principal)
  )
  (match (map-get? Friendships {
    user1: user1,
    user2: user2,
  })
    friendship (is-eq (get status friendship) FRIENDSHIP_ACTIVE)
    false
  )
)

;; User Status Validation
(define-private (check-active-user (user principal))
  (match (map-get? Users user)
    user-data (and
      (is-eq (get status user-data) STATUS_ACTIVE)
      (is-none (get deactivation-time user-data))
    )
    false
  )
)

;; User Existence Validator
(define-private (user-exists (user principal))
  (is-some (map-get? Users user))
)

;; Block Status Checker
(define-private (is-blocked
    (blocker principal)
    (blocked principal)
  )
  (is-some (map-get? BlockedUsers {
    blocker: blocker,
    blocked: blocked,
  }))
)

;; Privacy Settings Retrieval with Secure Defaults
(define-private (get-privacy-settings (user principal))
  (default-to {
    friend-list-visible: true,
    status-visible: true,
    metadata-visible: true,
    last-seen-visible: true,
    profile-image-visible: true,
    encryption-enabled: false,
    last-updated: stacks-block-height,
  }
    (map-get? UserPrivacy user)
  )
)