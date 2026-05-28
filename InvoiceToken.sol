// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title InvoiceToken
 * @notice TradeFlow — تحويل الفواتير التجارية إلى رموز رقمية (NFT)
 * @dev كل فاتورة تجارية تصبح NFT قابلة للتداول والتمويل
 */

contract InvoiceToken {
    
    // ============ المتغيرات ============
    address public owner;
    uint256 private _tokenIds;
    
    string public name = "TradeFlow Invoice Token";
    string public symbol = "TFIT";
    
    // ============ حالات الفاتورة ============
    enum InvoiceStatus {
        Pending,    // في الانتظار
        Approved,   // معتمدة
        Funded,     // ممولة
        Repaid,     // مسددة
        Defaulted   // متعثرة
    }
    
    // ============ هيكل الفاتورة ============
    struct Invoice {
        uint256 tokenId;
        address issuer;         // المُصدِر (الشركة الصغيرة)
        address buyer;          // المشتري (العميل)
        uint256 amount;         // قيمة الفاتورة (بالعملة المستقرة)
        uint256 dueDate;        // تاريخ الاستحقاق
        uint256 issuedAt;       // تاريخ الإصدار
        string invoiceNumber;   // رقم الفاتورة
        string description;     // وصف البضاعة/الخدمة
        InvoiceStatus status;   // الحالة الحالية
        bool isFunded;          // هل تم تمويلها؟
        address funder;         // الممول (إن وجد)
        uint256 fundedAmount;   // المبلغ الممول
    }
    
    // ============ التخزين ============
    mapping(uint256 => Invoice) public invoices;
    mapping(uint256 => address) public tokenOwner;
    mapping(address => uint256[]) public issuerInvoices;
    mapping(address => uint256) public totalInvoiceValue; // إجمالي قيمة فواتير كل شركة
    
    // ============ الأحداث ============
    event InvoiceCreated(
        uint256 indexed tokenId,
        address indexed issuer,
        address indexed buyer,
        uint256 amount,
        string invoiceNumber
    );
    
    event InvoiceApproved(uint256 indexed tokenId);
    event InvoiceFunded(uint256 indexed tokenId, address funder, uint256 amount);
    event InvoiceRepaid(uint256 indexed tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    // ============ المُعدِّلات ============
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier onlyTokenOwner(uint256 tokenId) {
        require(tokenOwner[tokenId] == msg.sender, "Not token owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // ============ الدوال الرئيسية ============
    
    /**
     * @notice إصدار فاتورة جديدة كـ NFT
     * @param buyer عنوان المشتري
     * @param amount قيمة الفاتورة
     * @param dueDate تاريخ الاستحقاق (Unix timestamp)
     * @param invoiceNumber رقم الفاتورة
     * @param description وصف البضاعة أو الخدمة
     */
    function issueInvoice(
        address buyer,
        uint256 amount,
        uint256 dueDate,
        string calldata invoiceNumber,
        string calldata description
    ) external returns (uint256) {
        require(buyer != address(0), "Invalid buyer address");
        require(amount > 0, "Amount must be > 0");
        require(dueDate > block.timestamp, "Due date must be in future");
        
        uint256 tokenId = ++_tokenIds;
        
        invoices[tokenId] = Invoice({
            tokenId: tokenId,
            issuer: msg.sender,
            buyer: buyer,
            amount: amount,
            dueDate: dueDate,
            issuedAt: block.timestamp,
            invoiceNumber: invoiceNumber,
            description: description,
            status: InvoiceStatus.Pending,
            isFunded: false,
            funder: address(0),
            fundedAmount: 0
        });
        
        tokenOwner[tokenId] = msg.sender;
        issuerInvoices[msg.sender].push(tokenId);
        totalInvoiceValue[msg.sender] += amount;
        
        emit InvoiceCreated(tokenId, msg.sender, buyer, amount, invoiceNumber);
        emit Transfer(address(0), msg.sender, tokenId);
        
        return tokenId;
    }
    
    /**
     * @notice اعتماد الفاتورة من طرف المشتري
     */
    function approveInvoice(uint256 tokenId) external {
        Invoice storage inv = invoices[tokenId];
        require(inv.buyer == msg.sender, "Only buyer can approve");
        require(inv.status == InvoiceStatus.Pending, "Invoice not pending");
        
        inv.status = InvoiceStatus.Approved;
        emit InvoiceApproved(tokenId);
    }
    
    /**
     * @notice تمويل فاتورة معتمدة (من قِبَل ممول)
     */
    function fundInvoice(uint256 tokenId) external payable {
        Invoice storage inv = invoices[tokenId];
        require(inv.status == InvoiceStatus.Approved, "Invoice not approved");
        require(!inv.isFunded, "Already funded");
        
        inv.status = InvoiceStatus.Funded;
        inv.isFunded = true;
        inv.funder = msg.sender;
        inv.fundedAmount = inv.amount;
        
        // نقل ملكية الـ NFT للممول
        address previousOwner = tokenOwner[tokenId];
        tokenOwner[tokenId] = msg.sender;
        
        emit InvoiceFunded(tokenId, msg.sender, inv.amount);
        emit Transfer(previousOwner, msg.sender, tokenId);
    }
    
    /**
     * @notice تسجيل سداد الفاتورة
     */
    function repayInvoice(uint256 tokenId) external onlyOwner {
        Invoice storage inv = invoices[tokenId];
        require(inv.status == InvoiceStatus.Funded, "Invoice not funded");
        
        inv.status = InvoiceStatus.Repaid;
        emit InvoiceRepaid(tokenId);
    }
    
    /**
     * @notice استعلام عن فواتير مُصدِر معين
     */
    function getIssuerInvoices(address issuer) 
        external view returns (uint256[] memory) {
        return issuerInvoices[issuer];
    }
    
    /**
     * @notice الحصول على تفاصيل فاتورة
     */
    function getInvoice(uint256 tokenId) 
        external view returns (Invoice memory) {
        return invoices[tokenId];
    }
    
    /**
     * @notice إجمالي عدد الفواتير المُصدَرة
     */
    function totalSupply() external view returns (uint256) {
        return _tokenIds;
    }
}
