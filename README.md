# Hybrid_Training_Management_System

## Introduction 🥁
The Hybrid Training Management System is designed to facilitate the management of various training programs, offering a comprehensive platform for scheduling, conducting, and tracking the progress of participants. Built on a robust SQL database framework, it ensures data integrity and provides a seamless experience for administrators and participants alike.

## Project Description 💻
This system is tailored to meet the needs of organizations looking to streamline their training operations. It supports both synchronous and asynchronous learning modules, making it versatile for different learning environments. The backend database plays a crucial role in managing the system's core functionalities, including user registration, module tracking, and performance assessments.

## Tables Description 📋
The database comprises several tables, each serving a unique purpose within the system. Below is a description of selected table:

### AsynchronicOnlineModules
* Purpose: Stores information about asynchronous online training modules, including recording links and expiration dates.
* Columns:
  + AsynchronicOnlineModuleID (int, Primary Key): A unique identifier for each asynchronous online module.
  + ModuleID (int): Identifier linking to the general module information.
  + RecordingLink (nvarchar(255)): URL to the online recording of the training session.
  + ExpirationDate (datetime): The date after which the module is no longer accessible.

## Integrity Conditions 🧲
Integrity conditions are crucial for maintaining data consistency and enforcing business logic within the database. Here are examples of such conditions applied in the project:
* Primary Key Constraint
* Foreign Key Constraint
* Check Constraints (Example descriptions of check constraints will be added here, such as constraints on ExpirationDate to ensure it's set in the future at the time of module creation.)

