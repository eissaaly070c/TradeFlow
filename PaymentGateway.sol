// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PaymentGateway
 * @notice TradeFlow — بوابة المدفوعات بالعملات المستقرة
 * @dev يقبل مدفوعات USDC/AED Stablecoin ويسجلها على Polygon
 */

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract PaymentGateway {
    
    // ============ المتغيرات الأساسية ============
    address public owner;
    IERC20 public stablecoin; // عنوان عقد USDC أو AED Stablecoin
    
    uint256 public totalPayments;     // إجمالي المدفوعات
    uint256 public totalVolume;       // إجمالي حجم التداول (بالـ wei)
    uint256 public platformFee = 50;  // 0.5% رسوم المنصة (50 = 0.5%)
    
    // ============ الهياكل ============
    struct Payment {
        uint256 id;
        address payer;        // المدفوع منه
        address merchant;     // التاجر المستلم
        uint256 amount;       // المبلغ
        uint256 timestamp;    // وقت الدفع
        string invoiceRef;    // رقم الفاتورة المرجعي
        bool settled;         // هل تم التسوية؟
    }
    
    // ============ التخزين ============
    mapping(uint256 => Payment) public payments;
    mapping(address => uint256[]) public merchantPayments;  // مدفوعات كل تاجر
    mapping(address => uint256) public merchantVolume;      // حجم تداول كل تاجر
    mapping(address => bool) public registeredMerchants;    // التجار المسجلون
    
    // ============ الأحداث ============
    event PaymentMade(
        uint256 indexed paymentId,
        address indexed payer,
        address indexed merchant,
        uint256 amount,
        string invoiceRef
    );
    
    event MerchantRegistered(address indexed merchant);
    event FeeUpdated(uint256 newFee);
    
    // ============ المُعدِّلات ============
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier onlyRegisteredMerchant() {
        require(registeredMerchants[msg.sender], "Not a registered merchant");
        _;
    }
    
    // ============ البناء ============
    constructor(address _stablecoinAddress) {
        owner = msg.sender;
        stablecoin = IERC20(_stablecoinAddress);
    }
    
    // ============ الدوال الرئيسية ============
    
    /**
     * @notice تسجيل تاجر جديد
     */
    function registerMerchant(address merchant) external onlyOwner {
        registeredMerchants[merchant] = true;
        emit MerchantRegistered(merchant);
    }
    
    /**
     * @notice دفع فاتورة لتاجر
     * @param merchant عنوان التاجر
     * @param amount المبلغ بالعملة المستقرة
     * @param invoiceRef رقم الفاتورة
     */
    function payInvoice(
        address merchant,
        uint256 amount,
        string calldata invoiceRef
    ) external returns (uint256) {
        require(registeredMerchants[merchant], "Merchant not registered");
        require(amount > 0, "Amount must be > 0");
        
        // حساب رسوم المنصة
        uint256 fee = (amount * platformFee) / 10000;
        uint256 merchantAmount = amount - fee;
        
        // تحويل من المدفوع إلى التاجر
        require(
            stablecoin.transferFrom(msg.sender, merchant, merchantAmount),
            "Transfer to merchant failed"
        );
        
        // تحويل الرسوم للمنصة
        if (fee > 0) {
            require(
                stablecoin.transferFrom(msg.sender, owner, fee),
                "Fee transfer failed"
            );
        }
        
        // تسجيل الدفع
        uint256 paymentId = ++totalPayments;
        payments[paymentId] = Payment({
            id: paymentId,
            payer: msg.sender,
            merchant: merchant,
            amount: amount,
            timestamp: block.timestamp,
            invoiceRef: invoiceRef,
            settled: true
        });
        
        merchantPayments[merchant].push(paymentId);
        merchantVolume[merchant] += amount;
        totalVolume += amount;
        
        emit PaymentMade(paymentId, msg.sender, merchant, amount, invoiceRef);
        
        return paymentId;
    }
    
    /**
     * @notice استعلام عن مدفوعات تاجر معين
     */
    function getMerchantPayments(address merchant) 
        external view returns (uint256[] memory) {
        return merchantPayments[merchant];
    }
    
    /**
     * @notice الحصول على تفاصيل دفعة
     */
    function getPayment(uint256 paymentId) 
        external view returns (Payment memory) {
        return payments[paymentId];
    }
    
    /**
     * @notice تحديث رسوم المنصة
     */
    function updateFee(uint256 newFee) external onlyOwner {
        require(newFee <= 500, "Fee cannot exceed 5%"); // حد أقصى 5%
        platformFee = newFee;
        emit FeeUpdated(newFee);
    }
}
