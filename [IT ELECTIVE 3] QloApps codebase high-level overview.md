# QloApps Codebase High-Level Overview

---

## **Main Purpose and Functionality**

QloApps is an open-source hotel reservation and booking engine. It enables hotels to launch a website, showcase properties, and manage bookings, customers, payments, and more. QloApps is built on top of a PHP-based e-commerce framework originally derived from PrestaShop.

---

## **Folder and File Structure**

- **index.php, init.php, header.php, footer.php**  
  Entry points and layout for the main site.

- **admin123/**  
  Admin panel files (controllers, templates, assets).

- **Adapter/**  
  Adapter classes for various integrations.

- **classes/**  
  Core business logic (e.g., controllers, models, helpers).

- **controllers/**  
  Main application controllers (admin and front).

- **config/**  
  Configuration files.

- **Core/**  
  Core framework classes and overrides.

- **modules/**  
  Add-on modules for extra features (each module is in its own folder).

- **themes/**  
  Frontend themes/templates.

- **tools/**  
  Utility libraries and third-party tools.

- **js/**, **css/**, **img/**  
  Static assets.

- **upload/**, **download/**  
  File storage.

- **translations/**, **localization/**  
  Language and localization files.

- **pdf/**, **mails/**  
  PDF generation and email templates.

- **webservice/**  
  Webservice API endpoints.

---

## **Key PHP Files and Classes**

- **index.php**  
  Main entry point for the frontend.

- **admin123/index.php**  
  Entry point for the admin backend.

- **classes/controller/Controller.php**  
  Base controller class.

- **classes/controller/AdminController.php**  
  Base class for admin controllers.

- **classes/controller/FrontController.php**  
  Base class for frontend controllers.

- **classes/Dispatcher.php**  
  Handles routing and dispatching requests to controllers.

- **config/config.inc.php**  
  Loads configuration and bootstraps the app.

- **modules/**  
  Each module can have its own controllers, classes, and templates.

---

## **Entry Points**

- **index.php** (root): Handles all frontend requests.
- **admin123/index.php**: Handles all admin requests.
- **modules/[modulename]/controllers/**: Module-specific controllers.

Routing is handled by **Dispatcher** (`classes/Dispatcher.php`), which maps URLs to the appropriate controller classes.

---

## **Notable Dependencies, Frameworks, or Libraries**

- **Smarty**: Templating engine for PHP.
- **PrestaShop Core**: Many classes and conventions are inherited from PrestaShop.
- **Composer**: For PHP dependency management (`composer.json`).
- **Third-party libraries**: Found in `tools/` (e.g., HTMLPurifier for HTML sanitization).

---

## **References for Customization**

- See how other modules are structured in `modules/` and, for example, [`modules/hotelreservationsystem/`](modules/hotelreservationsystem/).
- The main entry point for a module is the PHP file named after the module (e.g., `housekeepingmanagement.php`).

---
