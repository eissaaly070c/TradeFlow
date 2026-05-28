// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CreditScore
 * @notice TradeFlow — نظام التقييم الائتماني على البلوكتشين
 * @dev يبني سجلاً ائتمانياً شفافاً لكل شركة بناءً على سلوكها التجاري
 */

contract CreditScore {
    
    // ============ المتغيرات ============
    address public owner;
    address public paymentGateway;  // عنوان PaymentGateway
    address public invoiceToken;    // عنوان InvoiceToken
    
    uint256 public constant BASE_SCORE = 500;       // نقطة البداية
    uint256 public constant MAX_SCORE = 1000;       // الحد الأقصى
    uint256 public constant MIN_SCORE = 100;        // الحد الأدنى
    
    // ============ هيكل السجل الائتماني ============
    struct CreditProfile {
        address entity;             // عنوان الشركة
        uint256 score;              // النقاط الحالية (100-1000)
        uint256 totalPayments;      // إجمالي المدفوعات المنجزة
        uint256 onTimePayments;     // المدفوعات في الوقت المحدد
        uint256 latePayments;       // المدفوعات المتأخرة
        uint256 defaults;           // حالات التعثر
        uint256 totalInvoicesIssued;    // إجمالي الفواتير المُصدَرة
        uint256 totalInvoicesPaid;      // الفواتير المسددة
        uint256 totalVolumeTraded;      // إجمالي حجم التداول
        uint256 memberSince;            // تاريخ الانضمام
        uint256 lastActivity;           // آخر نشاط
        bool isRegistered;              // مسجل؟
    }
    
    // ============ التخزين ============
    mapping(address => CreditProfile) public profiles;
    address[] public registeredEntities;
    
    // ============ الأحداث ============
    event EntityRegistered(address indexed entity, uint256 initialScore);
    event ScoreUpdated(address indexed entity, uint256 oldScore, uint256 newScore, string reason);
    event PaymentRecorded(address indexed entity, bool onTime);
    event DefaultRecorded(address indexed entity);
    
    // ============ المُعدِّلات ============
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier onlyAuthorized() {
        require(
            msg.sender == owner || 
            msg.sender == paymentGateway || 
            msg.sender == invoiceToken,
            "Not authorized"
        );
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // ============ الإعداد ============
    
    function setPaymentGateway(address _gateway) external onlyOwner {
        paymentGateway = _gateway;
    }
    
    function setInvoiceToken(address _invoiceToken) external onlyOwner {
        invoiceToken = _invoiceToken;
    }
    
    // ============ الدوال الرئيسية ============
    
    /**
     * @notice تسجيل شركة جديدة
     */
    function registerEntity(address entity) external onlyOwner {
        require(!profiles[entity].isRegistered, "Already registered");
        
        profiles[entity] = CreditProfile({
            entity: entity,
            score: BASE_SCORE,
            totalPayments: 0,
            onTimePayments: 0,
            latePayments: 0,
            defaults: 0,
            totalInvoicesIssued: 0,
            totalInvoicesPaid: 0,
            totalVolumeTraded: 0,
            memberSince: block.timestamp,
            lastActivity: block.timestamp,
            isRegistered: true
        });
        
        registeredEntities.push(entity);
        emit EntityRegistered(entity, BASE_SCORE);
    }
    
    /**
     * @notice تسجيل دفعة (تلقائي من PaymentGateway)
     * @param entity عنوان الشركة
     * @param onTime هل كانت في الوقت المحدد؟
     * @param amount مبلغ الدفعة
     */
    function recordPayment(
        address entity,
        bool onTime,
        uint256 amount
    ) external onlyAuthorized {
        if (!profiles[entity].isRegistered) {
            _autoRegister(entity);
        }
        
        CreditProfile storage profile = profiles[entity];
        uint256 oldScore = profile.score;
        
        profile.totalPayments++;
        profile.totalVolumeTraded += amount;
        profile.lastActivity = block.timestamp;
        
        if (onTime) {
            profile.onTimePayments++;
            // مكافأة على الالتزام
            _increaseScore(entity, 5, "On-time payment");
        } else {
            profile.latePayments++;
            // خصم على التأخير
            _decreaseScore(entity, 10, "Late payment");
        }
        
        // مكافأة إضافية على الحجم الكبير
        if (amount > 10000 * 1e6) { // أكثر من 10,000 USDC
            _increaseScore(entity, 3, "High volume payment");
        }
        
        emit PaymentRecorded(entity, onTime);
    }
    
    /**
     * @notice تسجيل تعثر في السداد
     */
    function recordDefault(address entity) external onlyAuthorized {
        if (!profiles[entity].isRegistered) return;
        
        CreditProfile storage profile = profiles[entity];
        profile.defaults++;
        profile.lastActivity = block.timestamp;
        
        // عقوبة شديدة على التعثر
        _decreaseScore(entity, 100, "Payment default");
        
        emit DefaultRecorded(entity);
    }
    
    /**
     * @notice تسجيل إصدار فاتورة
     */
    function recordInvoiceIssued(address entity) external onlyAuthorized {
        if (!profiles[entity].isRegistered) {
            _autoRegister(entity);
        }
        profiles[entity].totalInvoicesIssued++;
        profiles[entity].lastActivity = block.timestamp;
    }
    
    /**
     * @notice تسجيل سداد فاتورة
     */
    function recordInvoicePaid(address entity) external onlyAuthorized {
        if (!profiles[entity].isRegistered) return;
        profiles[entity].totalInvoicesPaid++;
        _increaseScore(entity, 8, "Invoice repaid");
    }
    
    // ============ الاستعلامات ============
    
    /**
     * @notice الحصول على النقاط الائتمانية
     */
    function getScore(address entity) external view returns (uint256) {
        if (!profiles[entity].isRegistered) return BASE_SCORE;
        return profiles[entity].score;
    }
    
    /**
     * @notice الحصول على تصنيف الائتمان (A/B/C/D)
     */
    function getCreditRating(address entity) external view returns (string memory) {
        uint256 score;
        if (profiles[entity].isRegistered) {
            score = profiles[entity].score;
        } else {
            score = BASE_SCORE;
        }
        
        if (score >= 800) return "A - ممتاز";
        if (score >= 650) return "B - جيد جداً";
        if (score >= 500) return "C - جيد";
        if (score >= 350) return "D - مقبول";
        return "E - ضعيف";
    }
    
    /**
     * @notice الحصول على كامل ملف الائتمان
     */
    function getCreditProfile(address entity) 
        external view returns (CreditProfile memory) {
        return profiles[entity];
    }
    
    /**
     * @notice نسبة الالتزام بالسداد
     */
    function getPaymentReliability(address entity) 
        external view returns (uint256) {
        CreditProfile memory profile = profiles[entity];
        if (profile.totalPayments == 0) return 100; // لا سجل = افتراضي 100%
        
        return (profile.onTimePayments * 100) / profile.totalPayments;
    }
    
    // ============ دوال داخلية ============
    
    function _increaseScore(address entity, uint256 points, string memory reason) internal {
        CreditProfile storage profile = profiles[entity];
        uint256 oldScore = profile.score;
        
        profile.score = profile.score + points > MAX_SCORE 
            ? MAX_SCORE 
            : profile.score + points;
        
        if (profile.score != oldScore) {
            emit ScoreUpdated(entity, oldScore, profile.score, reason);
        }
    }
    
    function _decreaseScore(address entity, uint256 points, string memory reason) internal {
        CreditProfile storage profile = profiles[entity];
        uint256 oldScore = profile.score;
        
        profile.score = profile.score < points + MIN_SCORE 
            ? MIN_SCORE 
            : profile.score - points;
        
        if (profile.score != oldScore) {
            emit ScoreUpdated(entity, oldScore, profile.score, reason);
        }
    }
    
    function _autoRegister(address entity) internal {
        profiles[entity] = CreditProfile({
            entity: entity,
            score: BASE_SCORE,
            totalPayments: 0,
            onTimePayments: 0,
            latePayments: 0,
            defaults: 0,
            totalInvoicesIssued: 0,
            totalInvoicesPaid: 0,
            totalVolumeTraded: 0,
            memberSince: block.timestamp,
            lastActivity: block.timestamp,
            isRegistered: true
        });
        registeredEntities.push(entity);
        emit EntityRegistered(entity, BASE_SCORE);
    }
}
