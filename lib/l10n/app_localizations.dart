import 'package:flutter/material.dart';

enum AppLanguage { en, sv }

class AppLocale extends ChangeNotifier {
  AppLanguage _language = AppLanguage.en;

  AppLanguage get language => _language;

  void setLanguage(AppLanguage lang) {
    if (_language != lang) {
      _language = lang;
      notifyListeners();
    }
  }

  String get languageCode => _language == AppLanguage.en ? 'en' : 'sv';
  String get displayName => _language == AppLanguage.en ? 'English' : 'Svenska';
}

class S {
  static S of(BuildContext context) {
    final locale = AppLocaleProvider.of(context).language;
    return locale == AppLanguage.sv ? _Sv() : S();
  }

  // --- App-wide ---
  String get appTitle => "Dario's Store";
  String get brandName => "DARIO'S STORE";

  // --- Navigation ---
  String get navHome => 'Home';
  String get navCatalog => 'CATALOG';
  String get navSearch => 'SEARCH';
  String get navCart => 'CART';
  String get navProfile => 'PROFILE';
  String get navCatalogLabel => 'Catalog';
  String get navSearchLabel => 'Search';
  String get navCartLabel => 'Cart';
  String get navProfileLabel => 'Profile';

  // --- Home ---
  String get homeCategories => 'CATEGORIES';
  String get homeFeatured => 'FEATURED';
  String get homeAllProducts => 'ALL PRODUCTS';
  String get homeSeeAll => 'See all';
  String get heroTitle => "Flavors\nof Italy";
  String get heroSubtitle => 'Authentic Italian flavors,\ndelivered to your door.';
  String get heroButton => 'DISCOVER NOW';
  String get aboutTitle => 'OUR STORY';
  String get aboutText =>
      'From the rolling hills of Tuscany to your table. We source only the finest artisanal ingredients from family-run producers across Italy.';

  // --- Catalog ---
  String get catalogAll => 'All';
  String productCount(int n) => '$n PRODUCTS';
  String get catalogFeaturedBadge => 'FEATURED';

  // --- Search ---
  String get searchHint => 'Search products...';
  String get searchEmpty => 'Search our products';
  String get searchNoResults => 'No results';
  String get searchTryAnother => 'Try a different search';

  // --- Cart ---
  String get cartEmpty => 'Your cart is empty';
  String get cartEmptyDesc => 'Explore our products and add\nsomething special to your cart.';
  String get cartDiscover => 'DISCOVER PRODUCTS';
  String get cartTotal => 'TOTAL';
  String get cartShippingNote => 'Shipping calculated at checkout';
  String get cartCheckout => 'PROCEED TO CHECKOUT';

  // --- Profile ---
  String get profileWelcome => 'Welcome';
  String get profileSubtitle => 'Sign in to manage your orders';
  String get profileSignIn => 'SIGN IN';
  String get profileCreateAccount => 'CREATE ACCOUNT';
  String get profileMyOrders => 'My Orders';
  String get profileWishlist => 'Wishlist';
  String get profileAddresses => 'Addresses';
  String get profilePaymentMethods => 'Payment Methods';
  String get profileNotifications => 'Notifications';
  String get profileSupport => 'Support';
  String get profileAbout => 'About Us';
  String get profileAdmin => 'ADMIN PANEL';
  String get profileVersion => "DARIO'S STORE v1.0.0";
  String get profileLanguage => 'Language';

  // --- Product Detail ---
  String get detailBackToCatalog => 'Back to catalog';
  String get detailDescription => 'DESCRIPTION';
  String detailAddedToCart(String name) => '$name added to cart';
  String get detailAddToCart => 'ADD TO CART';
  String get detailBuyNow => 'BUY NOW';
  String get detailCategory => 'Category';
  String get detailRating => 'Rating';
  String get detailShipping => 'Shipping';
  String get detailShippingValue => 'Free over 50 kr';
  String get detailReturns => 'Returns';
  String get detailReturnsValue => '30 days';
  String get detailInStock => 'In Stock';
  String get detailOutOfStock => 'Out of Stock';
  String detailStockCount(int count) => '$count in stock';
  String stockLimitReached(String name) => 'Cannot add more $name — stock limit reached';

  // --- Footer ---
  String get footerTagline => 'Authentic Italian flavors,\ndelivered to your door.';
  String get footerShop => 'SHOP';
  String get footerCatalog => 'Catalog';
  String get footerFeaturedLink => 'Featured';
  String get footerNew => 'New';
  String get footerOffers => 'Offers';
  String get footerInfo => 'INFORMATION';
  String get footerAboutUs => 'About Us';
  String get footerContact => 'Contact';
  String get footerShippingLink => 'Shipping';
  String get footerReturnsLink => 'Returns';
  String get footerSupport => 'SUPPORT';
  String get footerFaq => 'FAQ';
  String get footerTerms => 'Terms & Conditions';
  String get footerPrivacy => 'Privacy Policy';
  String get footerCookies => 'Cookie Policy';
  String get footerCopyright => "© 2026 Dario's Store. All rights reserved.";

  // --- Nav ---
  String get navSupport => 'SUPPORT';
  String get navAbout => 'ABOUT';

  // --- Support Page ---
  String get supportPageTitle => 'SUPPORT';
  String get supportPageSubtitle => 'We are here to help you.';
  String get supportFaqTitle => 'Frequently Asked Questions';
  String get supportFaq1Q => 'How long does shipping take?';
  String get supportFaq1A => 'Standard shipping takes 3–5 business days within Sweden. Express delivery is available at checkout for next-day delivery.';
  String get supportFaq2Q => 'What is your return policy?';
  String get supportFaq2A => 'We accept returns within 30 days of delivery. Items must be unopened and in their original packaging.';
  String get supportFaq3Q => 'How can I track my order?';
  String get supportFaq3A => 'Once your order has shipped, you will receive an email with a tracking link. You can also check your order status under My Orders.';
  String get supportContactTitle => 'Contact Us';
  String get supportEmail => 'support@darios-store.com';
  String get supportPhone => '+46 8 123 45 67';
  String get supportHours => 'Mon–Fri, 09:00–17:00 CET';

  // --- About Page ---
  String get aboutMissionTitle => 'Our Mission';
  String get aboutMissionText => 'We believe everyone deserves access to authentic, high-quality Italian ingredients. Our mission is to bridge the gap between small Italian producers and food lovers around the world.';
  String get aboutValuesTitle => 'Our Values';
  String get aboutValuesText => 'Quality over quantity. Sustainability in every step. Direct partnerships with family-run producers. Transparent sourcing and fair pricing.';

  // --- Admin Shell ---
  String get adminTitle => "DARIO'S STORE — ADMIN";
  String get adminBackToStore => 'Back to store';
  String get adminDashboard => 'Dashboard';
  String get adminProducts => 'Products';
  String get adminCategories => 'Categories';
  String get adminOrders => 'Orders';
  String get adminPanelVersion => 'Admin Panel\nv1.0.0';

  // --- Admin Dashboard ---
  String get dashboardTitle => 'Dashboard';
  String get dashboardSubtitle => 'Store overview';
  String get dashboardServerError => 'Cannot connect to server.';
  String get dashboardRetry => 'RETRY';
  String get dashboardTotalProducts => 'Total Products';
  String get dashboardActiveProducts => 'Active Products';
  String get dashboardCategoriesStat => 'Categories';
  String get dashboardOrdersByStatus => 'Orders by Status';
  String get dashboardPending => 'Pending';
  String get dashboardConfirmed => 'Confirmed';
  String get dashboardShipped => 'Shipped';
  String get dashboardDelivered => 'Delivered';
  String get dashboardCancelled => 'Cancelled';
  String get dashboardQuickActions => 'Quick Actions';
  String get dashboardRefresh => 'REFRESH DATA';

  // --- Admin Products ---
  String get adminProductsTitle => 'Products';
  String adminProductsCount(int n) => '$n total products';
  String get adminNewProduct => 'NEW PRODUCT';
  String get adminRetry => 'RETRY';
  String get tableHeaderName => 'NAME';
  String get tableHeaderCategory => 'CATEGORY';
  String get tableHeaderPrice => 'PRICE';
  String get tableHeaderStock => 'STOCK';
  String get tableHeaderActive => 'ACTIVE';
  String get tableHeaderFeatured => 'FEATURED';
  String get tableHeaderActions => 'ACTIONS';
  String get confirmDelete => 'Confirm Deletion';
  String confirmDeleteProduct(String name) => 'Delete product "$name"?';
  String get cancel => 'CANCEL';
  String get delete => 'DELETE';
  String get edit => 'Edit';
  String errorMessage(String e) => 'Error: $e';

  // --- Admin Categories ---
  String get adminCategoriesTitle => 'Categories';
  String adminCategoriesCount(int n) => '$n total categories';
  String get adminNewCategory => 'NEW CATEGORY';
  String get tableHeaderDescription => 'DESCRIPTION';
  String get tableHeaderOrder => 'ORDER';
  String get editCategory => 'Edit Category';
  String get newCategory => 'New Category';
  String get formName => 'Name *';
  String get formDescription => 'Description';
  String get formSortOrder => 'Order';
  String get formActive => 'Active';
  String confirmDeleteCategory(String name) => 'Delete category "$name"?';
  String get save => 'SAVE';
  String get create => 'CREATE';

  // --- Admin Orders ---
  String get adminOrdersTitle => 'Orders';
  String adminOrdersCount(int n) => '$n orders';
  String get orderFilterAll => 'All';
  String get orderStatusPending => 'Pending';
  String get orderStatusConfirmed => 'Confirmed';
  String get orderStatusShipped => 'Shipped';
  String get orderStatusDelivered => 'Delivered';
  String get orderStatusCancelled => 'Cancelled';
  String get noOrdersFound => 'No orders found';
  String get tableHeaderId => 'ID';
  String get tableHeaderCustomer => 'CUSTOMER';
  String get tableHeaderTotal => 'TOTAL';
  String get tableHeaderStatus => 'STATUS';
  String get tableHeaderDate => 'DATE';
  String get confirmDeleteOrder => 'Delete this order?';
  String orderTitle(String id) => 'Order #$id';
  String get orderCustomer => 'Customer';
  String get orderEmail => 'Email';
  String get orderStatus => 'Status';
  String get orderTotal => 'Total';
  String get orderDate => 'Date';
  String get orderItems => 'Items:';
  String get close => 'CLOSE';
  String get orderDetails => 'Details';
  String get orderChangeStatus => 'Change status';

  // --- My Orders ---
  String get myOrdersTitle => 'My Orders';
  String get myOrdersEmpty => 'No orders yet';
  String get myOrdersEmptyDesc => 'Your order history will appear here\nonce you make a purchase.';
  String get myOrdersItem => 'item';
  String get myOrdersItems => 'items';

  // --- Wishlist ---
  String get wishlistTitle => 'Wishlist';
  String get wishlistEmpty => 'Your wishlist is empty';
  String get wishlistEmptyDesc => 'Browse our products and save your\nfavorites by tapping the heart icon.';
  String get wishlistBrowse => 'BROWSE PRODUCTS';
  String wishlistAdded(String name) => '$name added to wishlist';
  String wishlistRemoved(String name) => '$name removed from wishlist';

  // --- Addresses ---
  String get addressTitle => 'My Addresses';
  String get addressEmpty => 'No addresses saved';
  String get addressEmptyDesc => 'Add a delivery address to speed up\nyour checkout experience.';
  String get addressAdd => 'ADD ADDRESS';
  String get addressNewTitle => 'New Address';
  String get addressEditTitle => 'Edit Address';
  String get addressLabel => 'Label';
  String get addressFullName => 'Full Name';
  String get addressStreet => 'Street Address';
  String get addressStreet2 => 'Apartment, suite, etc. (optional)';
  String get addressCity => 'City';
  String get addressPostalCode => 'Postal Code';
  String get addressCountry => 'Country';
  String get addressPhone => 'Phone (optional)';
  String get addressDefault => 'Default';
  String get addressSetDefault => 'Set as default';
  String get addressSetAsDefault => 'Set as default address';
  String get addressDeleteConfirm => 'Delete Address';
  String addressDeleteMessage(String label) => 'Remove your "$label" address?';

  // --- Payment Methods ---
  String get paymentTitle => 'My Payment Methods';
  String get paymentEmpty => 'No payment methods saved';
  String get paymentEmptyDesc => 'Add a card securely via Stripe\nfor faster checkout.';
  String get paymentAdd => 'ADD PAYMENT METHOD';
  String get paymentLabel => 'Label';
  String get paymentEditLabel => 'Rename Card';
  String get paymentExpires => 'Expires';
  String get paymentDefault => 'Default';
  String get paymentSetDefault => 'Set as default';
  String get paymentSetAsDefault => 'Set as default payment method';
  String get paymentDeleteConfirm => 'Delete Payment Method';
  String paymentDeleteMessage(String label) => 'Remove your "$label" payment method?\nThe card will also be detached from Stripe.';
  String get paymentStripeSecure => 'Cards secured by Stripe';
  String get paymentSetupFailed => 'Failed to open card setup. Please try again.';

  // --- Admin Product Form ---
  String get formEditProduct => 'Edit Product';
  String get formNewProduct => 'New Product';
  String get formProductName => 'Name *';
  String get formProductDescription => 'Description *';
  String get formProductPrice => 'Price (kr) *';
  String get formProductCategory => 'Category *';
  String get formProductImageUrl => 'Image URL';
  String get formProductRating => 'Rating';
  String get formProductStock => 'Stock Quantity *';
  String get formInvalidStock => 'Invalid stock quantity';
  String get formProductActive => 'Active Product';
  String get formProductActiveDesc => 'Visible in store';
  String get formProductFeatured => 'Featured';
  String get formProductFeaturedDesc => 'Show in featured section';
  String get formCreateProduct => 'CREATE PRODUCT';
  String get formFieldRequired => 'Required field';
  String get formInvalidPrice => 'Invalid price';

  // --- Categories (mock data) ---
  String get catPasta => 'Pasta';
  String get catOliveOil => 'Olive Oil';
  String get catWine => 'Wine';
  String get catCheese => 'Cheese';
  String get catSauces => 'Sauces';
  String get catSweets => 'Sweets';

  // --- Auth ---
  String get authLogin => 'Sign In';
  String get authLoginTitle => 'SIGN IN';
  String get authLoginSubtitle => 'Welcome back';
  String get authRegister => 'Create Account';
  String get authRegisterTitle => 'CREATE ACCOUNT';
  String get authRegisterSubtitle => 'Join us today';
  String get authEmail => 'Email';
  String get authPassword => 'Password';
  String get authConfirmPassword => 'Confirm Password';
  String get authName => 'Full Name';
  String get authLogout => 'SIGN OUT';
  String get authNoAccount => "Don't have an account?";
  String get authHaveAccount => 'Already have an account?';
  String get authSignUpLink => 'Create one';
  String get authSignInLink => 'Sign in';
  String get authFieldRequired => 'This field is required';
  String get authInvalidEmail => 'Invalid email address';
  String get authPasswordTooShort => 'Password must be at least 8 characters';
  String get authPasswordsNoMatch => 'Passwords do not match';
  String get authLoginFailed => 'Invalid email or password';
  String get authRegisterFailed => 'Registration failed';

  // --- Checkout ---
  String get checkoutTitle => 'CHECKOUT';
  String get checkoutName => 'Full Name';
  String get checkoutEmail => 'Email Address';
  String get checkoutNameRequired => 'Please enter your name';
  String get checkoutEmailRequired => 'Please enter your email';
  String get checkoutEmailInvalid => 'Please enter a valid email';
  String get checkoutOrderSummary => 'ORDER SUMMARY';
  String checkoutItemLine(String name, int qty) => '$name x$qty';
  String get checkoutPlaceOrder => 'PLACE ORDER';
  String get checkoutProcessing => 'PROCESSING...';
  String get checkoutSuccessTitle => 'Order Placed!';
  String get checkoutSuccessMessage => 'Thank you for your order. You will receive a confirmation email shortly.';
  String get checkoutContinueShopping => 'CONTINUE SHOPPING';
  String get checkoutFailed => 'Failed to place order. Please try again.';
  String get checkoutStripeNotice => 'You will be redirected to Stripe to complete payment securely.';
  String get checkoutPaymentSecure => 'Payments secured by Stripe';
}

class _Sv extends S {
  // --- App-wide ---
  @override String get appTitle => "Dario's Store";
  @override String get brandName => "DARIO'S STORE";

  // --- Navigation ---
  @override String get navHome => 'Hem';
  @override String get navCatalog => 'KATALOG';
  @override String get navSearch => 'SÖK';
  @override String get navCart => 'VARUKORG';
  @override String get navProfile => 'PROFIL';
  @override String get navCatalogLabel => 'Katalog';
  @override String get navSearchLabel => 'Sök';
  @override String get navCartLabel => 'Varukorg';
  @override String get navProfileLabel => 'Profil';

  // --- Home ---
  @override String get homeCategories => 'KATEGORIER';
  @override String get homeFeatured => 'UTVALDA';
  @override String get homeAllProducts => 'ALLA PRODUKTER';
  @override String get homeSeeAll => 'Visa alla';
  @override String get heroTitle => "Smaker\nfrån Italien";
  @override String get heroSubtitle => 'Autentiska italienska smaker,\nlevererade till din dörr.';
  @override String get heroButton => 'UPPTÄCK NU';
  @override String get aboutTitle => 'VÅR HISTORIA';
  @override String get aboutText =>
      'Från Toscanas böljande kullar till ditt bord. Vi väljer bara de finaste hantverksmässiga ingredienserna från familjeägda producenter i hela Italien.';

  // --- Catalog ---
  @override String get catalogAll => 'Alla';
  @override String productCount(int n) => '$n PRODUKTER';
  @override String get catalogFeaturedBadge => 'UTVALD';

  // --- Search ---
  @override String get searchHint => 'Sök produkter...';
  @override String get searchEmpty => 'Sök bland våra produkter';
  @override String get searchNoResults => 'Inga resultat';
  @override String get searchTryAnother => 'Prova en annan sökning';

  // --- Cart ---
  @override String get cartEmpty => 'Din varukorg är tom';
  @override String get cartEmptyDesc => 'Utforska våra produkter och lägg till\nnågot speciellt i varukorgen.';
  @override String get cartDiscover => 'UPPTÄCK PRODUKTER';
  @override String get cartTotal => 'TOTALT';
  @override String get cartShippingNote => 'Frakt beräknas i kassan';
  @override String get cartCheckout => 'GÅ TILL KASSAN';

  // --- Profile ---
  @override String get profileWelcome => 'Välkommen';
  @override String get profileSubtitle => 'Logga in för att hantera dina beställningar';
  @override String get profileSignIn => 'LOGGA IN';
  @override String get profileCreateAccount => 'SKAPA KONTO';
  @override String get profileMyOrders => 'Mina Beställningar';
  @override String get profileWishlist => 'Önskelista';
  @override String get profileAddresses => 'Adresser';
  @override String get profilePaymentMethods => 'Betalningsmetoder';
  @override String get profileNotifications => 'Aviseringar';
  @override String get profileSupport => 'Support';
  @override String get profileAbout => 'Om Oss';
  @override String get profileAdmin => 'ADMINPANEL';
  @override String get profileVersion => "DARIO'S STORE v1.0.0";
  @override String get profileLanguage => 'Språk';

  // --- Product Detail ---
  @override String get detailBackToCatalog => 'Tillbaka till katalogen';
  @override String get detailDescription => 'BESKRIVNING';
  @override String detailAddedToCart(String name) => '$name tillagd i varukorgen';
  @override String get detailAddToCart => 'LÄGG I VARUKORG';
  @override String get detailBuyNow => 'KÖP NU';
  @override String get detailCategory => 'Kategori';
  @override String get detailRating => 'Betyg';
  @override String get detailShipping => 'Frakt';
  @override String get detailShippingValue => 'Gratis över 50 kr';
  @override String get detailReturns => 'Retur';
  @override String get detailReturnsValue => '30 dagar';
  @override String get detailInStock => 'I lager';
  @override String get detailOutOfStock => 'Slut i lager';
  @override String detailStockCount(int count) => '$count i lager';
  @override String stockLimitReached(String name) => 'Kan inte lägga till fler $name — lagergränsen nådd';

  // --- Footer ---
  @override String get footerTagline => 'Autentiska italienska smaker,\nlevererade till din dörr.';
  @override String get footerShop => 'BUTIK';
  @override String get footerCatalog => 'Katalog';
  @override String get footerFeaturedLink => 'Utvalda';
  @override String get footerNew => 'Nyheter';
  @override String get footerOffers => 'Erbjudanden';
  @override String get footerInfo => 'INFORMATION';
  @override String get footerAboutUs => 'Om Oss';
  @override String get footerContact => 'Kontakt';
  @override String get footerShippingLink => 'Frakt';
  @override String get footerReturnsLink => 'Returer';
  @override String get footerSupport => 'SUPPORT';
  @override String get footerFaq => 'FAQ';
  @override String get footerTerms => 'Villkor';
  @override String get footerPrivacy => 'Integritetspolicy';
  @override String get footerCookies => 'Cookiepolicy';
  @override String get footerCopyright => "© 2026 Dario's Store. Alla rättigheter förbehållna.";

  // --- Nav ---
  @override String get navSupport => 'SUPPORT';
  @override String get navAbout => 'OM OSS';

  // --- Support Page ---
  @override String get supportPageTitle => 'SUPPORT';
  @override String get supportPageSubtitle => 'Vi finns här för att hjälpa dig.';
  @override String get supportFaqTitle => 'Vanliga frågor';
  @override String get supportFaq1Q => 'Hur lång tid tar leveransen?';
  @override String get supportFaq1A => 'Standardleverans tar 3–5 arbetsdagar inom Sverige. Expressleverans finns tillgänglig vid kassan för leverans nästa dag.';
  @override String get supportFaq2Q => 'Vilken är er returpolicy?';
  @override String get supportFaq2A => 'Vi accepterar returer inom 30 dagar efter leverans. Varorna måste vara oöppnade och i originalförpackningen.';
  @override String get supportFaq3Q => 'Hur spårar jag min beställning?';
  @override String get supportFaq3A => 'När din beställning har skickats får du ett mejl med en spårningslänk. Du kan också se orderstatus under Mina beställningar.';
  @override String get supportContactTitle => 'Kontakta oss';
  @override String get supportEmail => 'support@darios-store.com';
  @override String get supportPhone => '+46 8 123 45 67';
  @override String get supportHours => 'Mån–Fre, 09:00–17:00 CET';

  // --- About Page ---
  @override String get aboutMissionTitle => 'Vårt uppdrag';
  @override String get aboutMissionText => 'Vi tror att alla förtjänar tillgång till autentiska italienska ingredienser av hög kvalitet. Vårt uppdrag är att överbrygga klyftan mellan små italienska producenter och matälskare runt om i världen.';
  @override String get aboutValuesTitle => 'Våra värderingar';
  @override String get aboutValuesText => 'Kvalitet framför kvantitet. Hållbarhet i varje steg. Direkta partnerskap med familjeägda producenter. Transparent inköp och rättvisa priser.';

  // --- Admin Shell ---
  @override String get adminTitle => "DARIO'S STORE — ADMIN";
  @override String get adminBackToStore => 'Tillbaka till butiken';
  @override String get adminDashboard => 'Översikt';
  @override String get adminProducts => 'Produkter';
  @override String get adminCategories => 'Kategorier';
  @override String get adminOrders => 'Beställningar';
  @override String get adminPanelVersion => 'Adminpanel\nv1.0.0';

  // --- Admin Dashboard ---
  @override String get dashboardTitle => 'Översikt';
  @override String get dashboardSubtitle => 'Butiksöversikt';
  @override String get dashboardServerError => 'Kan inte ansluta till servern.';
  @override String get dashboardRetry => 'FÖRSÖK IGEN';
  @override String get dashboardTotalProducts => 'Totalt Produkter';
  @override String get dashboardActiveProducts => 'Aktiva Produkter';
  @override String get dashboardCategoriesStat => 'Kategorier';
  @override String get dashboardOrdersByStatus => 'Beställningar per Status';
  @override String get dashboardPending => 'Väntande';
  @override String get dashboardConfirmed => 'Bekräftade';
  @override String get dashboardShipped => 'Skickade';
  @override String get dashboardDelivered => 'Levererade';
  @override String get dashboardCancelled => 'Avbokade';
  @override String get dashboardQuickActions => 'Snabbåtgärder';
  @override String get dashboardRefresh => 'UPPDATERA DATA';

  // --- Admin Products ---
  @override String get adminProductsTitle => 'Produkter';
  @override String adminProductsCount(int n) => '$n produkter totalt';
  @override String get adminNewProduct => 'NY PRODUKT';
  @override String get adminRetry => 'FÖRSÖK IGEN';
  @override String get tableHeaderName => 'NAMN';
  @override String get tableHeaderCategory => 'KATEGORI';
  @override String get tableHeaderPrice => 'PRIS';
  @override String get tableHeaderStock => 'LAGER';
  @override String get tableHeaderActive => 'AKTIV';
  @override String get tableHeaderFeatured => 'UTVALD';
  @override String get tableHeaderActions => 'ÅTGÄRDER';
  @override String get confirmDelete => 'Bekräfta Borttagning';
  @override String confirmDeleteProduct(String name) => 'Ta bort produkten "$name"?';
  @override String get cancel => 'AVBRYT';
  @override String get delete => 'TA BORT';
  @override String get edit => 'Redigera';
  @override String errorMessage(String e) => 'Fel: $e';

  // --- Admin Categories ---
  @override String get adminCategoriesTitle => 'Kategorier';
  @override String adminCategoriesCount(int n) => '$n kategorier totalt';
  @override String get adminNewCategory => 'NY KATEGORI';
  @override String get tableHeaderDescription => 'BESKRIVNING';
  @override String get tableHeaderOrder => 'ORDNING';
  @override String get editCategory => 'Redigera Kategori';
  @override String get newCategory => 'Ny Kategori';
  @override String get formName => 'Namn *';
  @override String get formDescription => 'Beskrivning';
  @override String get formSortOrder => 'Ordning';
  @override String get formActive => 'Aktiv';
  @override String confirmDeleteCategory(String name) => 'Ta bort kategorin "$name"?';
  @override String get save => 'SPARA';
  @override String get create => 'SKAPA';

  // --- Admin Orders ---
  @override String get adminOrdersTitle => 'Beställningar';
  @override String adminOrdersCount(int n) => '$n beställningar';
  @override String get orderFilterAll => 'Alla';
  @override String get orderStatusPending => 'Väntande';
  @override String get orderStatusConfirmed => 'Bekräftad';
  @override String get orderStatusShipped => 'Skickad';
  @override String get orderStatusDelivered => 'Levererad';
  @override String get orderStatusCancelled => 'Avbokad';
  @override String get noOrdersFound => 'Inga beställningar hittades';
  @override String get tableHeaderId => 'ID';
  @override String get tableHeaderCustomer => 'KUND';
  @override String get tableHeaderTotal => 'TOTALT';
  @override String get tableHeaderStatus => 'STATUS';
  @override String get tableHeaderDate => 'DATUM';
  @override String get confirmDeleteOrder => 'Ta bort denna beställning?';
  @override String orderTitle(String id) => 'Beställning #$id';
  @override String get orderCustomer => 'Kund';
  @override String get orderEmail => 'E-post';
  @override String get orderStatus => 'Status';
  @override String get orderTotal => 'Totalt';
  @override String get orderDate => 'Datum';
  @override String get orderItems => 'Artiklar:';
  @override String get close => 'STÄNG';
  @override String get orderDetails => 'Detaljer';
  @override String get orderChangeStatus => 'Ändra status';

  // --- My Orders ---
  @override String get myOrdersTitle => 'Mina Beställningar';
  @override String get myOrdersEmpty => 'Inga beställningar ännu';
  @override String get myOrdersEmptyDesc => 'Din orderhistorik visas här\nnär du har gjort ett köp.';
  @override String get myOrdersItem => 'artikel';
  @override String get myOrdersItems => 'artiklar';

  // --- Wishlist ---
  @override String get wishlistTitle => 'Önskelista';
  @override String get wishlistEmpty => 'Din önskelista är tom';
  @override String get wishlistEmptyDesc => 'Utforska våra produkter och spara dina\nfavoriter genom att trycka på hjärtikonen.';
  @override String get wishlistBrowse => 'UTFORSKA PRODUKTER';
  @override String wishlistAdded(String name) => '$name tillagd i önskelistan';
  @override String wishlistRemoved(String name) => '$name borttagen från önskelistan';

  // --- Addresses ---
  @override String get addressTitle => 'Mina Adresser';
  @override String get addressEmpty => 'Inga sparade adresser';
  @override String get addressEmptyDesc => 'Lägg till en leveransadress för att\nsnabba på din utcheckning.';
  @override String get addressAdd => 'LÄGG TILL ADRESS';
  @override String get addressNewTitle => 'Ny Adress';
  @override String get addressEditTitle => 'Redigera Adress';
  @override String get addressLabel => 'Etikett';
  @override String get addressFullName => 'Fullständigt namn';
  @override String get addressStreet => 'Gatuadress';
  @override String get addressStreet2 => 'Lägenhet, svit, etc. (valfritt)';
  @override String get addressCity => 'Stad';
  @override String get addressPostalCode => 'Postnummer';
  @override String get addressCountry => 'Land';
  @override String get addressPhone => 'Telefon (valfritt)';
  @override String get addressDefault => 'Standard';
  @override String get addressSetDefault => 'Ange som standard';
  @override String get addressSetAsDefault => 'Ange som standardadress';
  @override String get addressDeleteConfirm => 'Ta bort adress';
  @override String addressDeleteMessage(String label) => 'Ta bort din "$label"-adress?';

  // --- Payment Methods ---
  @override String get paymentTitle => 'Mina betalningsmetoder';
  @override String get paymentEmpty => 'Inga betalningsmetoder sparade';
  @override String get paymentEmptyDesc => 'Lägg till ett kort säkert via Stripe\nför snabbare betalning.';
  @override String get paymentAdd => 'LÄGG TILL BETALNINGSMETOD';
  @override String get paymentLabel => 'Etikett';
  @override String get paymentEditLabel => 'Byt namn på kort';
  @override String get paymentExpires => 'Utgår';
  @override String get paymentDefault => 'Standard';
  @override String get paymentSetDefault => 'Ange som standard';
  @override String get paymentSetAsDefault => 'Ange som standardbetalningsmetod';
  @override String get paymentDeleteConfirm => 'Ta bort betalningsmetod';
  @override String paymentDeleteMessage(String label) => 'Ta bort din "$label"-betalningsmetod?\nKortet kopplas också bort från Stripe.';
  @override String get paymentStripeSecure => 'Kort säkrade av Stripe';
  @override String get paymentSetupFailed => 'Kunde inte öppna kortregistrering. Försök igen.';

  // --- Admin Product Form ---
  @override String get formEditProduct => 'Redigera Produkt';
  @override String get formNewProduct => 'Ny Produkt';
  @override String get formProductName => 'Namn *';
  @override String get formProductDescription => 'Beskrivning *';
  @override String get formProductPrice => 'Pris (kr) *';
  @override String get formProductCategory => 'Kategori *';
  @override String get formProductImageUrl => 'Bild-URL';
  @override String get formProductRating => 'Betyg';
  @override String get formProductStock => 'Lagerantal *';
  @override String get formInvalidStock => 'Ogiltigt lagerantal';
  @override String get formProductActive => 'Aktiv Produkt';
  @override String get formProductActiveDesc => 'Synlig i butiken';
  @override String get formProductFeatured => 'Utvald';
  @override String get formProductFeaturedDesc => 'Visa i utvalda-sektionen';
  @override String get formCreateProduct => 'SKAPA PRODUKT';
  @override String get formFieldRequired => 'Obligatoriskt fält';
  @override String get formInvalidPrice => 'Ogiltigt pris';

  // --- Categories (mock data) ---
  @override String get catPasta => 'Pasta';
  @override String get catOliveOil => 'Olivolja';
  @override String get catWine => 'Vin';
  @override String get catCheese => 'Ost';
  @override String get catSauces => 'Såser';
  @override String get catSweets => 'Sötsaker';

  // --- Auth ---
  @override String get authLogin => 'Logga in';
  @override String get authLoginTitle => 'LOGGA IN';
  @override String get authLoginSubtitle => 'Välkommen tillbaka';
  @override String get authRegister => 'Skapa konto';
  @override String get authRegisterTitle => 'SKAPA KONTO';
  @override String get authRegisterSubtitle => 'Gå med idag';
  @override String get authEmail => 'E-post';
  @override String get authPassword => 'Lösenord';
  @override String get authConfirmPassword => 'Bekräfta lösenord';
  @override String get authName => 'Fullständigt namn';
  @override String get authLogout => 'LOGGA UT';
  @override String get authNoAccount => 'Har du inget konto?';
  @override String get authHaveAccount => 'Har du redan ett konto?';
  @override String get authSignUpLink => 'Skapa ett';
  @override String get authSignInLink => 'Logga in';
  @override String get authFieldRequired => 'Detta fält är obligatoriskt';
  @override String get authInvalidEmail => 'Ogiltig e-postadress';
  @override String get authPasswordTooShort => 'Lösenordet måste vara minst 8 tecken';
  @override String get authPasswordsNoMatch => 'Lösenorden matchar inte';
  @override String get authLoginFailed => 'Ogiltig e-post eller lösenord';
  @override String get authRegisterFailed => 'Registreringen misslyckades';

  // --- Checkout ---
  @override String get checkoutTitle => 'KASSA';
  @override String get checkoutName => 'Fullständigt namn';
  @override String get checkoutEmail => 'E-postadress';
  @override String get checkoutNameRequired => 'Ange ditt namn';
  @override String get checkoutEmailRequired => 'Ange din e-post';
  @override String get checkoutEmailInvalid => 'Ange en giltig e-postadress';
  @override String get checkoutOrderSummary => 'ORDERÖVERSIKT';
  @override String checkoutItemLine(String name, int qty) => '$name x$qty';
  @override String get checkoutPlaceOrder => 'LÄGG BESTÄLLNING';
  @override String get checkoutProcessing => 'BEARBETAR...';
  @override String get checkoutSuccessTitle => 'Beställning lagd!';
  @override String get checkoutSuccessMessage => 'Tack för din beställning. Du kommer att få ett bekräftelsemail inom kort.';
  @override String get checkoutContinueShopping => 'FORTSÄTT HANDLA';
  @override String get checkoutFailed => 'Beställningen misslyckades. Försök igen.';
  @override String get checkoutStripeNotice => 'Du omdirigeras till Stripe för säker betalning.';
  @override String get checkoutPaymentSecure => 'Betalningar säkrade av Stripe';
}

class AppLocaleProvider extends InheritedNotifier<AppLocale> {
  const AppLocaleProvider({
    super.key,
    required AppLocale locale,
    required super.child,
  }) : super(notifier: locale);

  static AppLocale of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppLocaleProvider>()!.notifier!;
  }
}
