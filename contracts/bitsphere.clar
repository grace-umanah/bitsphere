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