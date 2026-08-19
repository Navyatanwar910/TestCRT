*** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Library    DateTime    # Required for timestamp generation
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome
Suite Teardown          Close All Browsers

*** Variables ***
${INVALID_ACRONYM}        ABCDFRGT123456BGRTiqn2112
${CONTACT_NAME}           Navya Tanwar
${TRANSFER_COURSE}        AIP 2026

*** Test Cases ***

Login To Salesforce Instance
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    5VKQODUZSH
    ClickText     Verify
    VerifyText    Home

Login as Finance User
    [Documentation]    login in Salesforce  
    ClickText    Setup
    ClickText    Opens in a new tab
    SwitchWindow    NEW
    ClickText    Debbie Bishko
    ClickText    Login
    ClickText    Programs

# SECTION 1: PROGRAM SETUP & MANDATORY DATA VALIDATION

Verify Finance Can Create A Valid Program
    [Documentation]    Verify CoreTech/Finance can create a valid program with all mandatory setup data and that the program is available for downstream enrollment and financial processing.

# Generate timestamp and dynamic program name at runtime
    ${timestamp}=      Get Current Date               result_format=%Y%m%d-%H%M%S
    ${PROGRAM_NAME}=   Set Variable                   Program-Auto-${timestamp}
    ${Acronym}=        Set Variable                   ACR-${timestamp}
    Set Suite Variable    ${PROGRAM_NAME}
    Set Suite Variable    ${Acronym}

    ClickText          Programs                       anchor=Home
    ClickElement       xpath=//a[@title='New']
    VerifyText         New Program                    anchor=Cancel
    ClickText          Open Enrollment
    ClickText          Next
    TypeText           Program Name                   ${PROGRAM_NAME}
    TypeText           Acronym                        ${Acronym}
    TypeText           Start Date                     09/01/2026
    TypeText           End Date                       08/31/2027
    TypeText           Program Fee                    200000
    DropDown           Acceptance Criteria            Application/Admission
    DropDown           Program Status                 Confirmed
    ClickText          Save                           timeout=20s
    VerifyText         The Program was successfully created!
    ClickText          Finish
    Sleep              5s
    VerifyText         ${Acronym} - September 2026

Verify setting up email template 
    [Documentation]    Test Case created using the QEditor
    
    # Generate random 4-digit number
    ${PROJECT_NUM}=    Evaluate    random.randint(1000, 9999)    modules=random
    Set Suite Variable             ${PROJECT_NUM}
    
    ClickText          Details    anchor=Content    recognition_mode=vision
    ClickText    Financials    anchor=OE
    ClickText    Edit PTA-Project Number
    TypeText     PTA-Project Number                 ${PROJECT_NUM}
    ClickText          --None--                       anchor=PTA-Award
    ClickText          EAFJY
    ComboBox    Search Invoice Templates...    Standard OE Invoice Template    index=1
    ClickText    Save
    ClickText    Admit Email
    ClickText    Admit Email Setup
    ClickText    Email Template  
    ClickText    Admit - On Campus
    ClickText    Save

Verify Creation of Participants
    [Documentation]    Test Case created using the QEditor
    ClickText    Overview
    ClickText    New
    ClickText    Contact    partial_match=False
    TypeText    Search for a contact...    Navya Tan
    ClickText                        ${CONTACT_NAME}
    ClickText    Stage
    ClickText    Pending                   recognition_mode=vision
    ClickText    Save

Verify Program Creation Prevention On Invalid Data
    [Documentation]    Verify program creation is prevented when mandatory fields are missing, invalid, duplicate, or inconsistent.
    [Tags]             Negative
    ClickText          Programs                       anchor=Home
    ClickElement       xpath=//a[@title='New']
    ClickText          Open Enrollment
    ClickText          Next
    TypeText           Program Name                   Invalid Acronym Test
    TypeText           Acronym                        ${INVALID_ACRONYM}
    TypeText           Start Date                     09/01/2026
    TypeText           End Date                       08/31/2026
    ClickText          Save
    VerifyText         Acronym length should not exceed 25 characters
    VerifyText         End Date and must be on or after Start Date.
    VerifyText         End Date is required and must be on or after Start Date.
    Sleep              5s
    ClickText          Cancel

# SECTION 2: ENROLLMENT CHANGES & REVERTS (NO PAYMENT)

Login as PL
    [Documentation]    Test Case created using the QEditor
    ClickText          Log out
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    5VKQODUZSH
    ClickText     Verify
    VerifyText    Home
    ClickText    Setup
    ClickText    Opens in a new tab
    SwitchWindow    NEW
    ClickText    Justina Kayastha
    ClickText    Login
    ClickText    Home

Verify Admission of Participant as PL
    [Documentation]    Test Case created using the QEditor
    ClickText          Programs    anchor=Home
    ClickText          Search...
    ClickElement     xpath=//input[contains(@placeholder,'Search Programs and more...')]    
    TypeText         Search Programs and more...    ${Acronym}     
    ClickText        ${Acronym} - September 2026
    Sleep            5s
    ClickText        Enrollment                     anchor=Overview
    ClickText        Pending | Applicant
    ClickElement    xpath=//tr[.//a[contains(text(),'Navya Tanwar')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText       Admit with Invoice and Email
    ClickText       Select Email Template
    ClickText       Admit - On Campus
    ClickText       Send Email(s)
    Sleep           5s

Verify Participant Can Make Successful Direct Payment through credit card
    [Documentation]    Verify Participant/Payer can make a successful full direct payment and that the invoice, payment, balance, and enrollment status update correctly.
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    5VKQODUZSH
    ClickText     Verify
    VerifyText    Home
    ClickText     Programs
    ClickText    Search...
    ClickElement     xpath=//input[contains(@placeholder,'Search...')]    
    TypeText          Search...        ${Acronym}     
    ClickText         ${Acronym} - September 2026   
    ClickText          PayExed
    ClickElement       xpath=//a[starts-with(text(),'ACR-')]
    Sleep              5s
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    TypeText           Card number                    4111111111111111
    TypeText           Expiration date                    10/29
    TypeText           Security code                  123
    ClickText          PAY NOW
    VerifyText         Your payment was successful!
    VerifyText         PAYMENT TRANSACTION
    Sleep              5s
    SwitchWindow       2
    RefreshPage
    VerifyText         Invoice Status
    VerifyText         Paid
    VerifyText         Transaction Payments
    VerifyText         Invoice Balance
    ScrollTo           Child Invoices
    Sleep              5s 
#Verify Transactions Related List Table
    VerifyText         Transaction Number             anchor=Transactions
    VerifyText         PT-                        anchor=Transactions
    VerifyText         Transaction Type               anchor=Transactions
    VerifyText         Payment                        anchor=Transactions
    VerifyText         Amount                         anchor=Transaction
    VerifyText         $200,000.00                    anchor=Transactions
    
Verify raising a Cancellation Request as PL
    [Documentation]    Test Case created using the QEditor
    ClickText    Setup
    ClickText    Opens in a new tab
    SwitchWindow    NEW
    ClickText    Justina Kayastha
    ClickText    Login
    ClickText    Home
    ClickText          Programs    anchor=Home
    ClickText          Search...
    ClickElement     xpath=//input[contains(@placeholder,'Search Programs and more...')]    
    TypeText         Search Programs and more...    ${Acronym}     
    ClickText        ${Acronym} - September 2026
    Sleep            5s
    ClickText          PayExed
    ClickElement       xpath=//tr[.//a[contains(text(),'Navya Tanwar')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Finance Request
    VerifyText         Fee Payer(s):
    ClickText          Please select a type
    ClickText          Cancel
    ClickText          Refund Amount
    TypeText           Refund Amount                      100000
    ClickText          Comments
    TypeText           Comments                        Cancel
    ClickText          Submit
    ClickText          View New Finance Request
    Sleep              5s
    
Login as Finance User to check for finance requests and create a manual Payment
    [Documentation]    Test Case created using the QEditor
    ClickText          Log out
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    5VKQODUZSH
    ClickText     Verify
    VerifyText    Home    
    ClickText    Setup
    ClickText    Opens in a new tab
    SwitchWindow    NEW
    ClickText    Debbie Bishko
    ClickText    Login
    ClickText    Home
    ClickText    Programs
    ClickText    ${Acronym} - September 2026    
    ClickText          PayExed
    ClickElement       xpath=//a[starts-with(text(),'ACR-')]
    SwitchWindow       NEW
    Sleep              2s
    ClickElement       xpath=//button[text()='Create Payment / Refund']
    UseModal           On

    # Dropdown & Input Selections
    ClickText          Payment         anchor=Payment Type
    ClickText          Refund          anchor=Payment
    ClickText          --None--                       anchor=Payment Method
    ClickText          Credit Card                    anchor=ACH/Wire
    ClickText          --None--                       anchor=Transaction
    ClickElement       xpath=//span[starts-with(text(),'PT-')][1]
    TypeText           Amount                         1000000                     # Adjust refund amount as needed
    
    # Form Submission
    ClickElement       xpath=//button[@name='SaveEdit' or text()='Save'] 
    VerifyText         Refund Amount cannot exceed the original transaction amount  
    Sleep              5s 
    TypeText           Amount                         100000                     # Adjust refund amount as needed 
    UseModal           Off
    VerifyText         Secure Public Id
    ClickText          ACR-                        anchor=Invoice              partial_match=True    
    VerifyText         Invoice Status
    VerifyText         Paid
    VerifyText         Invoice Balance
    ScrollTo           Transactions
    VerifyText         Transaction Number             anchor=Transactions
    Sleep              5s 

    ClickElement       xpath=//one-app-nav-bar-item-root[.//span[text()='Tasks']]//a    
    ClickText    Select list display
    ClickText    Table
    ClickText    Select a List View: Tasks
    ClickText    Finance Requests      anchor=Completed Tasks    index=2
    ClickText    Create Date
    ClickText    Financial Request - Cancel    anchor=justinak
    ClickText    Cancel+Refund                 anchor=Action
    ClickText    Submit Cancellation           recognition_mode=vision
    Sleep        5s
