# User Registration Feature

**Sania Awale**
**Investra Trading Platform**

## User Story

**As a** registered user of the Investra platform  
**I want to** log in with my email and password and log out when finished  
**So that** I can securely access my account and protect my information

### Acceptance Criteria 

### 1. Successful Login with Role Based Redirection
Registered users can log in with their email and password. Upon successful authentication, a session is created and the user is redirected to role-appropriate dashboard. Invalid credentials display "Invalid email or password" error.

### 2. Login failed with Invalid Credentials
if a user attempts to log in with incorrect email or password, the system displays "Invalid email or password" error message and the user remains on the login page.

### 3. Successful Logout from Any Page
Users can successfully log out using the logout button from any page. Logout completely destroys the user session and redirects to the login page.

### 5. Session Management
User session persists across page navigation while logged in. Session is destroyed upon logout.

## MVC Components

### Models

* A `User` model with `email:string`, `password_digest:string`, `first_name:string`, `last_name:string`, `phone_number:string`, and `company_id:integer` attributes.

* A `Role` model with `name:string` and `description:text` attributes.

* A `UserRole` model with `user_id:integer` and `role_id:integer` attributes (join table for many-to-many relationship).

* A `Company` model with `name:string` and `domain:string` attributes.

### Views

* A `sessions/new.html.erb` view — displays login form with fields for email and password.

* A `dashboard/index.html.erb` view — Trader dashboard 

* A `dashboard/associate.html.erb` view — Associate Trader dashboard 

* A `dashboard/manager.html.erb` view — Portfolio Manager  dashboard

* A `dashboard/admin.html.erb` view — System Administrator panel 

### Controllers

* A `SessionsController` with `new` (shows login form), `create` (processes login and creates session), and `destroy` (logs out user and destroys session) actions.

* A `DashboardController` with `index` (displays role-appropriate dashboard based on current user's role) action.

* An `ApplicationController` - base controller with helper methods for authentication (`current_user`, `logged_in?`, `require_login`) and authorization (`authorize_role`).


