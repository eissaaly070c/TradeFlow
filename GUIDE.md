# 🚀 TradeFlow — الدليل الشامل للنشر والتقديم

---

## 📌 ما هو TradeFlow؟

**TradeFlow** منصة بلوكتشين تحل مشكلتين رئيسيتين في سوق الإمارات:

1. **تمويل التجارة للشركات الصغيرة** — تحويل الفواتير لرموز رقمية قابلة للتمويل الفوري
2. **مدفوعات التجار** — قبول العملات المستقرة مع بناء سجل ائتماني تلقائي

**مبنية على:** Polygon Amoy Testnet  
**اللغة:** Solidity 0.8.20  
**الجائزة المستهدفة:** Smart Commerce Infrastructure Challenge — $25,000 USDC

---

## 📁 هيكل الملفات

```
TradeFlow/
├── contracts/
│   ├── PaymentGateway.sol    ← قبول المدفوعات بالعملات المستقرة
│   ├── InvoiceToken.sol      ← تحويل الفواتير لـ NFT
│   └── CreditScore.sol       ← التقييم الائتماني على السلسلة
├── frontend/
│   └── index.html            ← الواجهة الكاملة (HTML/CSS/JS)
└── docs/
    └── GUIDE.md              ← هذا الملف
```

---

## 🛠️ المرحلة 1: إعداد البيئة

### ✅ الأدوات المطلوبة (تعمل من المتصفح)

| الأداة | الرابط | الاستخدام |
|--------|--------|-----------|
| Remix IDE | remix.ethereum.org | كتابة ونشر العقود |
| MetaMask | metamask.io | المحفظة الرقمية |

---

## 🔧 المرحلة 2: إعداد MetaMask على Polygon Amoy

### الخطوات:
1. افتح تطبيق MetaMask
2. اضغط على اسم الشبكة في الأعلى
3. اضغط **Add Network** ← **Add a network manually**
4. أدخل البيانات التالية:

```
Network Name:    Polygon Amoy Testnet
RPC URL:         https://rpc-amoy.polygon.technology
Chain ID:        80002
Currency Symbol: MATIC
Block Explorer:  https://amoy.polygonscan.com
```

5. احفظ ← ستتحول للشبكة الجديدة

### الحصول على رصيد مجاني (Testnet Faucet):
1. اذهب إلى: **faucet.polygon.technology**
2. الصق عنوان محفظتك
3. ستصلك MATIC مجانية خلال دقيقتين

---

## 📝 المرحلة 3: رفع الكود على Remix IDE

### الخطوة 1: فتح Remix
- افتح **remix.ethereum.org** من متصفحك

### الخطوة 2: إنشاء الملفات
في الشريط الأيسر اضغط على **📁 File Explorer**

اضغط على أيقونة **+** لإنشاء ملف جديد:

**ملف 1:** `PaymentGateway.sol`  
← الصق كامل كود PaymentGateway.sol

**ملف 2:** `InvoiceToken.sol`  
← الصق كامل كود InvoiceToken.sol

**ملف 3:** `CreditScore.sol`  
← الصق كامل كود CreditScore.sol

---

## ⚙️ المرحلة 4: تجميع العقود (Compile)

1. اضغط على أيقونة **Solidity Compiler** (⚙️) في الشريط الأيسر
2. في **Compiler Version** اختر: `0.8.20`
3. فعّل خيار **Auto compile**
4. افتح كل ملف ← تأكد أنه لا توجد أخطاء حمراء

**إذا ظهر خطأ:** ابحث عن السطر المحدد وتحقق من نسخ الكود بشكل صحيح.

---

## 🚀 المرحلة 5: نشر العقود (Deploy)

### الخطوة 1: ربط MetaMask
1. اضغط على أيقونة **Deploy & Run** (الصاروخ 🚀)
2. في قائمة **ENVIRONMENT** اختر: `Injected Provider - MetaMask`
3. ستظهر نافذة MetaMask للموافقة ← اضغط **Connect**
4. تأكد أن الشبكة: **Polygon Amoy (80002)**

### الخطوة 2: نشر CreditScore أولاً
1. في قائمة **CONTRACT** اختر: `CreditScore`
2. اضغط **Deploy**
3. وافق على المعاملة في MetaMask
4. في الأسفل ستظهر تحت **Deployed Contracts**
5. **📋 احفظ العنوان** — ستحتاجه لاحقاً

### الخطوة 3: نشر InvoiceToken
1. في **CONTRACT** اختر: `InvoiceToken`
2. اضغط **Deploy**
3. **📋 احفظ العنوان**

### الخطوة 4: نشر PaymentGateway
1. في **CONTRACT** اختر: `PaymentGateway`
2. في حقل المدخلات أدخل عنوان USDC Testnet:
   ```
   _stablecoinAddress: 0x41E94Eb019C0762f9Bfcf9Fb1E58725BfB0e7582
   ```
3. اضغط **Deploy**
4. **📋 احفظ العنوان**

---

## 🔗 المرحلة 6: ربط العقود ببعض

### في عقد CreditScore:
بعد النشر اضغط على العقد في قائمة **Deployed Contracts**

استدعِ الدالة `setPaymentGateway`:
```
_gateway: [عنوان_PaymentGateway_الذي_احفظته]
```

استدعِ الدالة `setInvoiceToken`:
```
_invoiceToken: [عنوان_InvoiceToken_الذي_احفظته]
```

### في عقد PaymentGateway:
استدعِ `registerMerchant`:
```
merchant: [عنوان_محفظتك]
```

---

## ✅ المرحلة 7: اختبار المشروع

### اختبار 1: إرسال دفعة
```
1. في PaymentGateway استدعِ: payInvoice
   merchant: [عنوان محفظة ثانية]
   amount: 1000000 (= 1 USDC - 6 decimals)
   invoiceRef: "INV-001"
```

### اختبار 2: إصدار فاتورة NFT
```
1. في InvoiceToken استدعِ: issueInvoice
   buyer: [عنوان المشتري]
   amount: 5000000000 (= 5000 USDC)
   dueDate: [Unix timestamp بعد شهر]
   invoiceNumber: "INV-2026-001"
   description: "Electronics Import"
```

### اختبار 3: التحقق من النقاط الائتمانية
```
1. في CreditScore استدعِ: getScore
   entity: [عنوان محفظتك]
   → يجب أن يُعيد رقماً بين 100 و 1000
```

---

## 🌐 المرحلة 8: نشر الواجهة

### خيار 1: Replit (مجاني - للاختبار)
1. اذهب إلى **replit.com**
2. اضغط **Create Repl** ← اختر **HTML, CSS, JS**
3. الصق كامل محتوى `index.html`
4. اضغط **Run** ← ستحصل على رابط مباشر

### خيار 2: GitHub Pages (مجاني - للإنتاج)
1. أنشئ حساب على **github.com**
2. أنشئ Repository جديد
3. ارفع ملف index.html
4. Settings ← Pages ← Deploy from branch
5. ستحصل على رابط: `yourusername.github.io/tradeflow`

---

## 📊 نموذج الإيرادات

| المصدر | التفاصيل | النسبة |
|--------|---------|--------|
| رسوم المعاملات | 0.5% من كل دفعة | أساسي |
| رسوم التمويل | 1-2% من قيمة الفاتورة الممولة | رئيسي |
| خدمات الائتمان | تقارير تفصيلية للبنوك | مستقبلي |
| API للمؤسسات | وصول للبيانات الائتمانية | مستقبلي |

**مثال:** 1000 معاملة شهرية × متوسط $5000 × 0.5% = **$25,000/شهر**

---

## 📋 ملف التقديم للمسابقة

### ما تحتاجه:

**1. Team Background (خلفية الفريق)**
```
اذكر: خبرتك في البرمجة، اهتمامك بالبلوكتشين،
هدفك من المشاركة.
```

**2. Problem Statement (المشكلة)**
```
المشكلة 1: $2 تريليون فجوة في تمويل التجارة العالمية.
40% من طلبات الشركات الصغيرة مرفوضة.
خطابات الاعتماد تستغرق 7-10 أيام يدوية.

المشكلة 2: الإمارات تستهدف 90% معاملات بدون نقد.
التجار يفتقرون لأدوات قبول العملات المستقرة.
```

**3. Technical Architecture**
```
- 3 عقود ذكية على Polygon Amoy
- PaymentGateway: قبول USDC/AED Stablecoin
- InvoiceToken: ERC-721 NFT للفواتير التجارية
- CreditScore: تقييم ائتماني تلقائي على السلسلة
- واجهة HTML/JS تتصل بـ MetaMask
```

**4. Launch Roadmap**
```
الشهر 1: نشر على Amoy Testnet + MVP
الشهر 2: اختبار مع 10 تجار
الشهر 3: إطلاق على Polygon Mainnet
الشهر 6: الوصول لـ 100 تاجر في دبي
```

**5. Revenue Model**
```
رسوم 0.5% على كل معاملة
رسوم 1% على تمويل الفواتير
هدف: $50K شهرياً خلال سنة
```

### رابط التقديم:
**app.ignyte.ae/public/challenges**

---

## ❓ أسئلة شائعة

**س: ما الفرق بين Testnet و Mainnet؟**  
ج: Testnet للتجربة المجانية. Mainnet للإنتاج الحقيقي بأموال حقيقية.

**س: هل أحتاج MATIC حقيقية للتقديم؟**  
ج: لا — Amoy Testnet مجانية تماماً للتطوير.

**س: هل يمكن التقديم بمشروع جزئي؟**  
ج: نعم — MVP أو نموذج أولي مقبول.

**س: ماذا تعني "on-chain readiness"؟**  
ج: أن عقودك منشورة فعلاً على بلوكتشين (testnet مقبول).

---

## 📞 مصادر مفيدة

| المصدر | الرابط |
|--------|--------|
| Polygon Docs | docs.polygon.technology |
| Remix IDE | remix.ethereum.org |
| Amoy Faucet | faucet.polygon.technology |
| Amoy Explorer | amoy.polygonscan.com |
| المسابقة | app.ignyte.ae/public/challenges |

---

*TradeFlow — Built for DIFC Smart Commerce Infrastructure Challenge 2026*
