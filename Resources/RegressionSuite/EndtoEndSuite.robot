*** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Library    DateTime    # Required for timestamp generation
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome
Suite Teardown          Close All Browsers
Resource    Login_Keywords.resource

*** Variables ***
${VALID_ACRONYM}          ABCDFRGT123456BGRTiqn21
${INVALID_ACRONYM}        ABCDFRGT123456BGRTiqn2112
${CONTACT_NAME}           Navya Tanwar
${PAYER_NAME}             Diana Brown
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
# ==============================================================================

Verify Finance Can Create A Valid Program
    [Documentation]    Verify CoreTech/Finance can create a valid program with all mandatory setup data and that the program is available for downstream enrollment and financial processing.

# Generate timestamp and dynamic program name at runtime
    ${timestamp}=      Get Current Date               result_format=%Y%m%d-%H%M%S
    ${PROGRAM_NAME}=   Set Variable                   Program-Auto-${timestamp}
    ${Acronym}=        Set Variable                   Acronym-Auto-${timestamp}
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
    
    ClickText          Details    anchor=Content    recognition_mode=vision
    ClickText    Financials    anchor=PayExed
    ClickText    PTA-Project Number
    TypeText     PTA-Project Number                 1256
    DropDown     PTA-Award                        EAFJY
    ClickText    Edit Invoice Template
    ComboBox    Search Invoice Templates...    Standard OE Invoice Template    index=1
    ClickText    Save
    ClickText    Admit Email
    ClickText    Admit Email Setup
    ClickText    Email Template  
    ClickText    Admit - On Campus
    ClickText    Save
Verify Creation of Participant
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


# ==============================================================================
# SECTION 2: ENROLLMENT CHANGES & REVERTS (NO PAYMENT)
# ==============================================================================

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
    TypeText      Verification Code    5YJXMZKRHI
    ClickText     Verify
    VerifyText    Home
    ClickText    Setup
    ClickText    Opens in a new tab
    SwitchWindow    NEW
    ClickText    Justina Kayastha
    ClickText    Login
    ClickText    Programs              anchor=Home
    ClickText    Search...
    ClickElement     xpath=//input[contains(@placeholder,'Search Programs and more...')]    
    TypeText          Search Programs and more...    ${Acronym}     
    ClickText       ${Acronym} - September 2026 - September 2026    

Verify Admission of Participant as PL
    [Documentation]    Test Case created using the QEditor
    
    ClickText          Enrollment    anchor=Overview
    ClickText          Pending | Applicant
    ClickElement       xpath=//tr[.//a[contains(text(),'Navya Tanwar')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText    Admit with Invoice and Email
    ClickText    Select Email Template
    ClickText    Admit - On Campus
    ClickText    Send Email(s)

Verify Cancellation request as PL
    ClickText          PayExed
    ClickElement       xpath=//tr[.//a[contains(text(),'Navya Tanwar')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Finance Request
    VerifyText         Fee Payer(s):
    ClickText          Please select a type
    ClickText          Cancel
    ClickText          Refund Amount
    TypeText           Refund Amount                      20000
    ClickText          Comments
    TypeText           Comments                        Cancel
    ClickText          Submit
    ClickText          View New Finance Request
    Sleep              5s
 

Login as Finance User to check for finance requests
    [Documentation]    Test Case created using the QEditor
    ClickText          logout
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    5YJXMZKRHI
    ClickText     Verify
    VerifyText    Home    
    ClickText    Setup
    ClickText    Opens in a new tab
    SwitchWindow    NEW
    ClickText    Debbie Bishko
    ClickText    Login
    ClickText    Home
    ClickElement       xpath=//one-app-nav-bar-item-root[.//span[text()='Tasks']]//a    
    ClickText    Select list display
    ClickText    Table
    ClickText    Select a List View: Tasks
    ClickText    Finance Requests      anchor=Completed Tasks    index=2
    ClickText    Create Date
    ClickText    Financial Request - Cancel    anchor=justinak
    ClickText    Cancel + Refund
    ClickText    Submit Cancellation           recognition_mode=vision

Verify PL Can Revert Cancellation
    [Documentation]    Verify PL can revert an enrollment change without payment and that all related records return to their previous valid state.
    ClickText          Log out
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    5YJXMZKRHI
    ClickText     Verify
    VerifyText    Home
    ClickText    Setup
    ClickText    Opens in a new tab
    SwitchWindow    NEW
    ClickText    Justina Kayastha
    ClickText    Login
    ClickText    Programs              anchor=Home
    ClickText    Search...
    ClickElement     xpath=//input[contains(@placeholder,'Search Programs and more...')]    
    TypeText          Search Programs and more...    ${Acronym}     
    ClickText         ${Acronym} - September 2026    
    ClickText          Navya Tanwar
    ClickElement       xpath=//button[text()='Revert Cancel' or @title='Revert Cancel']
    Sleep              5s
    RefreshPage
    VerifyText         Funnel Stage

Verify a finance request is raised for reverting the Cancellation
    [Documentation]    Check for a request as finance user
    ClickText          Log out
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    5YJXMZKRHI
    ClickText     Verify
    VerifyText    Home    
    ClickText    Setup
    ClickText    Opens in a new tab
    SwitchWindow    NEW
    ClickText    Debbie Bishko
    ClickText    Login
    ClickText    Home
    ClickElement       xpath=//one-app-nav-bar-item-root[.//span[text()='Tasks']]//a    
    ClickText    Select list display
    ClickText    Table
    ClickText    Select a List View: Tasks
    ClickText    Finance Requests      anchor=Completed Tasks    index=2
    ClickText    Create Date
    ClickText    Revert    anchor=justinak
    ClickText    Revert Cancel

# ==============================================================================
# SECTION 3: DIRECT PAYMENTS (FULL, PARTIAL, METHODS, ERRORS, DUPLICATES)
# ==============================================================================

Verify Participant Can Make Successful Partial Direct Payment through credit card
    [Documentation]    Verify Participant/Payer can make a successful full direct payment and that the invoice, payment, balance, and enrollment status update correctly.
    ClickText          Log out
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    5YJXMZKRHI
    ClickText     Verify
    VerifyText    Home
    ClickText     Programs
    ClickText    Search...
    ClickElement     xpath=//input[contains(@placeholder,'Search...')]    
    TypeText          Search...    ${Acronym}     
    ClickText       ${Acronym} - September 2026   
    ClickText          PayExed
    ClickText          ${Acronym}-R6450
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    ClickText          Payment Amount (USD)
    TypeText           Payment Amount (USD)          25000
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
    VerifyText         Partially Paid
    VerifyText         Transaction Payments
    VerifyText         Invoice Balance
    ScrollTo           Child Invoices
    Sleep              10s

Verify Failed Direct Payments Do Not Update Financial Status
    [Documentation]    Verify failed, declined, cancelled, or invalid direct payments do not incorrectly update invoice or enrollment financial status.
    [Tags]             Negative
    ScrollTo           PDF Preview
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    ClickText          Payment Amount (USD)
    TypeText           Payment Amount (USD)          25000
    TypeText           Card number                    4000000000000002
    TypeText           Expiration date                    10/29
    TypeText           Security code                  123
    ClickText          PAY NOW 
    VerifyText         Your card was declined.
    Sleep              5s
    SwitchWindow       2
   
Verify Participant Can Make Successful Partial Direct Payment through Amazon Pay
    [Documentation]    Verify Participant/Payer can make a successful partial direct payment and that the remaining balance is calculated correctly.
    ScrollTo           PDF Preview
    ClickElement       xpath=//a[contains(@href,'pay')]
    ClickText          Make Payment
    ClickText          Amazon Pay
    ClickText          PAY NOW
    ClickText          Authorize Test Payment
    VerifyText         Your payment was successful!
    Sleep              5s
    SwitchWindow       2
    RefreshPage
    VerifyText         Invoice Status
    VerifyText         Paid
    VerifyText         Transaction Payments
    VerifyText         Invoice Balance
    ScrollTo           Child Invoices
    Sleep              10s

# ==============================================================================
# SECTION 4: POST-PAYMENT ENROLLMENT CHANGES & REFUNDS
# ==============================================================================

Verify Partial Manual Refund Processing with finance user
    [Documentation]    Verify PL/Finance can process a full online refund for an enrollment change and that the payment, invoice, balance, and enrollment records are reconciled.
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    5YJXMZKRHI
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
    ClickText          Testing4-R6450
    ClickElement       xpath=//*[text()='Create Payment / Refund']
    UseModal           On

    # Dropdown & Input Selections
    DropDown       Payment Type                   Refund
    TypeText           Amount                         2000                     # Adjust refund amount as needed
    DropDown       Transaction                 PT-2055922 - $24800.00 - Available
    DropDown       Payment Method                 Credit Card               # Replace with applicable method

    # Form Submission
    ClickText          Save
    UseModal           Off
    

Verify Invalid Refund Processing Prevention
    [Documentation]    Verify invalid, duplicate, excessive, or unsupported refunds are rejected without corrupting financial balances.
    [Tags]             Negative
    ClickText          Testing3-R6449
    ClickElement       xpath=//*[text()='Create Payment / Refund']
    UseModal           On

    # Dropdown & Input Selections
    DropDown       Payment Type                   Refund
    TypeText           Amount                         200000                     # Adjust refund amount as needed
    DropDown       Transaction                 PT-2055922 - $24800.00 - Available
    DropDown       Payment Method                 Credit Card               # Replace with applicable method

    # Form Submission
    ClickText          Save
    UseModal           Off
    VerifyText         Error

# ==============================================================================
# SECTION 5: CREDITS & CREDIT TRANSFERS
# ==============================================================================

Verify Transfer of Participant to another program where the payment made is partial by the Participant
    [Documentation]    Transfer Actions
    ClickText          PayExed
    ClickElement       xpath=//tr[.//a[contains(text(),'Navya Tanwar')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Finance Request
    ClickText          Please select a type    anchor=Request Type:
    ClickText    Transfer               
    TypeText    Search for a course...    AIP\n    anchor=To Course
    ClickText    AIP 2027 
    TypeText     Please provide detailed information about your request...     test
    ClickText    Submit

    ClickText     View New Finance Request
    VerifyText    Financial Request - Transfer
    ClickText     Transfer                        anchor=Action
    sleep         2s
    ClickText     Submit Transfer
    ClickElement       xpath=//one-app-nav-bar-item-root[.//span[text()='Tasks']]//a    
    ClickText    Select list display
    ClickText    Table
    ClickText    Select a List View: Tasks
    ClickText    Finance Requests      anchor=Completed Tasks    index=2
    ClickText    Create Date
    ClickText    Financial Request - Transfer    
    ClickElement                       xpath=//a[contains(@href,'Transfer')]
    ClickText                        Submit Transfer             anchor=cancel
    ClickText                        Programs
    ClickText                        Testing4 - September 2026
    ClickText                        Enrollment                  anchor=Overview
    ClickText                        Transfer 
    ClickText                        AIP 2027  
    SwitchWindow                     NEW
    ClickText                        Enrollment                  anchor=Overview  
    VerifyText                       Credit Balance   
    ClickText                        Navya Tanwar   
    SwitchWindow                     NEW 
    ClickText                        Financials                  anchor=Logistics   
    VerifyText                       Credit Balance
    Sleep                        10s
       
Verify Participant is transfer to another program after making full payment of previous program.
    SwitchWindow    3
    ClickText                        Enrollment                  anchor=Overview  
    ClickElement       xpath=//tr[.//a[contains(text(),'Navya Tanwar')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText         Transfer    anchor=Withdraw
    TypeText    Search for a course...    AIP\n    anchor=To Course
    ClickText    AIP3                 anchor=To Course
    TypeText     Please provide detailed information about your request...     test
    ClickText    Submit 
    ClickText     View New Finance Request
    VerifyText    Financial Request - Transfer
    ClickText     Transfer                        anchor=Action
    sleep         2s
    ClickText     Submit Transfer
    ClickText     AIP3 - November 2027

Verify Spliting of Unpaid Invoice
    ClickText    Programs
    ClickText    Testing3 0 September 2026
    ClickText          PayExed
    ClickText          Testing3-R6449
    SwitchWindow       NEW
    ClickText          Split Invoice    recognition_mode=vision
    UseModal           on
    Sleep              2s
    
Verify Validations on User Defined Split Invoice
    SetConfig    ShadowDOM    True
    VerifyText                Amount Validation   
    VerifyText                  Original Invoice Amount   
    VerifyText                  Total Split Amount       
    ClickText                   Add Split   
    TypeText                    Percent                    50.00%    anchor=Split Type
    TypeText                    Days                       30        anchor=Due Date Type
    ScrollTo                     Remove    anchor=Days
    ClickText                    Add Split
    ScrollTo                     Remove    anchor=Days
    Sleep                        5s
    TypeText                     Percent             40.00%    anchor=Remove
    TypeText                     Days                20        anchor=Remove
    VerifyText                   Validation Errors
    Sleep                        5s    
    ClickText                    Cancel              anchor=Submit

Verify split of invoice with user defined template where invoice status is Unpaid and split is based on Percentage
    [Documentation]    Template based

    Sleep              2s
    ClickText          Split Invoice    recognition_mode=vision
    UseModal           on
    Sleep              2s
    SetConfig          ShadowDOM    True       
    ClickText                   Add Split   
    TypeText                    Percent                    60.00%    anchor=Split Type
    TypeText                    Days                       30        anchor=Due Date Type
    ScrollTo                     Remove    anchor=Days
    ClickText                    Add Split
    ScrollTo                     Remove    anchor=Days
    Sleep                        5s
    TypeText                     Percent             40.00%    anchor=Remove
    TypeText                     Days                20        anchor=Remove
    Sleep                        5s    
    ClickText                    Submit                anchor=Cancel
    Sleep                        5s
    ScrollTo                     Child Invoices
    VerifyText                   Invoice Number
    VerifyText                   Net Invoice Amount        
    VerifyText                   Invoice Status
    ClickText                    Due Date
    Sleep                        5s
    ClickText                    PDF Preview
    Sleep                        5s
    ClickText                    Details
    VerifyText                   Invoice Status
    VerifyText                   Unpaid
    VerifyText                   Due Date
    ClickElement                 xpath=//a[text()='Pay']
    SwitchWindow                 NEW
    ClickText                    Make Payment
    Sleep                        5s
    ClickText                    Amazon Pay
    ClickText                    PAY NOW
    ClickText                    AUTHORIZE TEST PAYMENT
    VerifyText                   Paid
    SwitchWindow                 2
    RefreshPage
    VerifyText                   Invoice Status
    VerifyText                   Paid
    ClickElement                 xpath=//span[text()='Parent Invoice']/following::a[1]
    VerifyText                   Invoice Status
    VerifyText                   Partially Paid
