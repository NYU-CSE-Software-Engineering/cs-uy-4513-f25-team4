# User Registration Feature

**Sania Awale**
**Investra Trading Platform**

## User Story

**As a** new visitor to the Investra platform  
**I want to** register for an account with my email and password  
**So that** I can access the trading platform and manage my investments

### Acceptance Criteria

### 1. Happy Successful registration with unique email 
Users can register with a unique email, password (minimum 8 characters), password confirmation, first name, and last name. The system assigns the default "Trader" role upon successful registration. If the email is already taken, the system displays "Email is already taken" error message.

### 2. Password Length Validation
If the password is less than 8 characters, the system displays "Password is too short (minimum is 8 characters)" error message.

### 3. Password Confirmation Matching
If password and password confirmation do not match, the system displays "Password confirmation doesn't match" error message.

### 4. Secure Password Storage
Passwords are hashed before storage using bcrypt. Plain text passwords are never stored in the database.

### 5. Automatic Role Assignment
Upon successful registration, the system automatically assigns the default "Trader" role to the new user and logs them in automatically, redirecting to the dashboard.

### Models

* A `User` model with `email:string`, `password_digest:string`, `first_name:string`, `last_name:string`, `phone_number:string`, and `company_id:integer` attributes.

* A `Role` model with `name:string` attributes.

* A `UserRole` model with `user_id:integer` and `role_id:integer` attributes.

* A `Company` model with `name:string` and `domain:string` attributes.

### Views

* A `users/new.html.erb` view — displays registration form with fields for email, password, password confirmation, first name, and last name.

### Controllers

* A `UsersController` with `new` (shows registration form) and `create` (processes registration) actions.

