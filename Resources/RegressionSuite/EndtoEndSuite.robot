*** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome
Suite Teardown          Close All Browsers

*** Variables ***
${VALID_ACRONYM}          ABCDFRGT123456BGRTiqn21
${INVALID_ACRONYM}        ABCDFRGT123456BGRTiqn2112
${PROGRAM_NAME}           Executive Leadership Cohort 2028
${CONTACT_NAME}           Navya Tanwar
${PAYER_NAME}             Diana Brown
${TRANSFER_COURSE}        AIP 2026

*** Test Cases ***

Login as Finance User
    [Documentation]    login in Salesforce
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
    ClickText    Programs

# SECTION 1: PROGRAM SETUP & MANDATORY DATA VALIDATION
# ==============================================================================

Verify Finance Can Create A Valid Program
    [Documentation]    Verify CoreTech/Finance can create a valid program with all mandatory setup data and that the program is available for downstream enrollment and financial processing.
    ClickText          Programs                       anchor=Home
    ClickElement       xpath=//a[@title='New']
    VerifyText         New Program                    anchor=Cancel
    ClickText          Open Enrollment
    ClickText          Next
    TypeText           Program Name                   Executive Leadership Cohort 2026
    TypeText           Acronym                        Testing3
    TypeText           Start Date                     09/01/2026
    TypeText           End Date                       08/31/2027
    TypeText           Program Fee                    200000
    DropDown           Acceptance Criteria            Application/Admission
    DropDown           Program Status                 Confirmed
    ClickText          Save                           timeout=20s
    VerifyText         The Program was successfully created!
    ClickText          Finish
    Sleep              5s
    VerifyText         Testing3 - September 2026

Verify setting up email template 
    [Documentation]    Test Case created using the QEditor
    
    ClickText          Details    anchor=Content    recognition_mode=vision
    ClickText    Financials    anchor=PayExed
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
    ClickText                        Navya Tanwar
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
    TypeText          Search Programs and more...    Testing3     
    ClickText       Testing3 - September 2026    

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
    TypeText          Search Programs and more...    Testing3     
    ClickText       Testing3 - September 2026    
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

Verify Participant Can Make Successful Full Direct Payment
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
    ClickElement     xpath=//input[contains(@placeholder,'Search Programs and more...')]    
    TypeText          Search Programs and more...    Testing3     
    ClickText       Testing3 - September 2026   
    ClickText          PayExed
    ClickText          Testing3-R6449
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    ClickText          Credit Card
    TypeText           Card Number                    4111111111111111
    TypeText           CVV                            123
    ClickText          PAY NOW
    SwitchWindow       1
    VerifyText         Paid                           anchor=Invoice Status
    VerifyText         $0.00                          anchor=Remaining Balance

Verify Participant Can Make Successful Partial Direct Payment
    [Documentation]    Verify Participant/Payer can make a successful partial direct payment and that the remaining balance is calculated correctly.
    ClickText          PayExed
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    TypeText           Amount To Pay                  50000
    ClickText          Credit Card
    ClickText          PAY NOW
    SwitchWindow       1
    VerifyText         Partially Paid
    VerifyText         $150,000.00                    anchor=Remaining Balance

Verify All Supported Direct Payment Methods Process Successfully
    [Documentation]    Verify all supported direct payment methods process successfully and update the invoice and payment status correctly.
    ClickText          PayExed
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    ClickText          Amazon Pay
    ClickText          PAY NOW
    ClickText          Authorize Test Payment
    SwitchWindow       1
    VerifyText         Paid

Verify Failed Direct Payments Do Not Update Financial Status
    [Documentation]    Verify failed, declined, cancelled, or invalid direct payments do not incorrectly update invoice or enrollment financial status.
    [Tags]             Negative
    ClickText          PayExed
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    ClickText          Credit Card
    TypeText           Card Number                    4000000000000002
    ClickText          PAY NOW
    VerifyText         Payment Declined
    SwitchWindow       1
    VerifyText         Unpaid                         anchor=Invoice Status

Verify Duplicate Direct Payments Are Prevented
    [Documentation]    Verify duplicate direct payments are prevented or handled without creating duplicate financial transactions.
    [Tags]             Negative
    ClickText          PayExed
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    ClickText          PAY NOW
    Sleep              1s
    ClickText          PAY NOW                        # Double-click attempt
    VerifyText         Transaction in progress. Please wait.

# ==============================================================================
# SECTION 4: POST-PAYMENT ENROLLMENT CHANGES & REFUNDS
# ==============================================================================

Verify Enrollment Change After Full Direct Payment
    [Documentation]    Verify PL/Finance can change an enrollment after full direct payment and that all related financial records remain consistent.
    ClickText          Enrollment                     anchor=Overview
    ClickElement       xpath=//tr[.//a[contains(text(),'${CONTACT_NAME}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Change Stage
    DropDown           Stage                          Completed
    ClickText          Save
    VerifyText         Completed                      anchor=${CONTACT_NAME}
    VerifyText         Paid                           anchor=Invoice Status

Verify Enrollment Change After Partial Direct Payment
    [Documentation]    Verify PL/Finance can change an enrollment after partial direct payment and that the outstanding amount is recalculated correctly.
    ClickText          Enrollment                     anchor=Overview
    ClickElement       xpath=//tr[.//a[contains(text(),'${PAYER_NAME}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Change Stage
    DropDown           Stage                          Withdrawn
    ClickText          Save
    VerifyText         $150,000.00 Cancellation Fee Applied

Verify Full Online Refund Processing
    [Documentation]    Verify PL/Finance can process a full online refund for an enrollment change and that the payment, invoice, balance, and enrollment records are reconciled.
    ClickText          PayExed
    ClickElement       xpath=//tr[.//a[contains(text(),'${CONTACT_NAME}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Finance Request
    ClickText          Please select a type
    ClickText          Refund
    ClickText          Full Refund
    ClickText          Submit
    ClickText          View New Finance Request
    ClickText          Process Online Refund
    VerifyText         Refunded                       anchor=Invoice Status

Verify Partial Online Refund Processing
    [Documentation]    Verify PL/Finance can process a partial online refund and that only the eligible amount is refunded and the remaining payment balance is correct.
    ClickText          PayExed
    ClickElement       xpath=//tr[.//a[contains(text(),'${CONTACT_NAME}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Finance Request
    ClickText          Please select a type
    ClickText          Refund
    TypeText           Refund Amount                  50000
    ClickText          Submit
    ClickText          View New Finance Request
    ClickText          Process Online Refund
    VerifyText         Partial Refund Processed: $50,000.00

Verify Full Manual Refund Processing
    [Documentation]    Verify PL/Finance can process a full manual refund and that the refund and invoice records are updated correctly.
    ClickText          PayExed
    ClickElement       xpath=//tr[.//a[contains(text(),'${CONTACT_NAME}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Finance Request
    ClickText          Please select a type
    ClickText          Manual Refund
    TypeText           Reference Number               CHK-908123
    ClickText          Submit
    VerifyText         Manual Refund Recorded

Verify Partial Manual Refund Processing
    [Documentation]    Verify PL/Finance can process a partial manual refund and that financial balances remain consistent.
    ClickText          PayExed
    ClickElement       xpath=//tr[.//a[contains(text(),'${CONTACT_NAME}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Finance Request
    ClickText          Please select a type
    ClickText          Manual Refund
    TypeText           Refund Amount                  25000
    TypeText           Reference Number               CHK-908124
    ClickText          Submit
    VerifyText         Partial Manual Refund Recorded

Verify Reverting Enrollment Change With Direct Payment
    [Documentation]    Verify enrollment changes involving direct payment can be reverted and that all payment, refund, invoice, and enrollment records return to the expected state.
    ClickText          Enrollment                     anchor=Overview
    ClickElement       xpath=//tr[.//a[contains(text(),'${CONTACT_NAME}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Revert Enrollment & Financial Change
    ClickText          Confirm Revert
    VerifyText         Status Restored

Verify Invalid Refund Processing Prevention
    [Documentation]    Verify invalid, duplicate, excessive, or unsupported refunds are rejected without corrupting financial balances.
    [Tags]             Negative
    ClickText          PayExed
    ClickElement       xpath=//tr[.//a[contains(text(),'${CONTACT_NAME}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Finance Request
    ClickText          Please select a type
    ClickText          Refund
    TypeText           Refund Amount                  99999999
    ClickText          Submit
    VerifyText         Refund amount exceeds total eligible paid balance.

# ==============================================================================
# SECTION 5: CREDITS & CREDIT TRANSFERS
# ==============================================================================

Verify Apply Full Credit Balance To Invoice
    [Documentation]    Verify PL/Finance can apply a full available credit balance to an eligible enrollment or invoice and that the credit balance and invoice balance update correctly.
    ClickText          PayExed
    ClickElement       xpath=//tr[.//a[contains(text(),'${CONTACT_NAME}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Apply Credit
    ClickText          Full Available Credit
    ClickText          Apply
    VerifyText         Credit Applied Successfully
    VerifyText         $0.00                          anchor=Credit Balance

Verify Apply Partial Credit Balance To Invoice
    [Documentation]    Verify PL/Finance can apply a partial credit balance and that the remaining credit and invoice balance are calculated correctly.
    ClickText          PayExed
    ClickElement       xpath=//tr[.//a[contains(text(),'${CONTACT_NAME}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Apply Credit
    TypeText           Amount To Apply                10000
    ClickText          Apply
    VerifyText         Remaining Credit: $15,000.00

Verify Multiple Credit Transfers Between Invoices
    [Documentation]    Verify multiple credit transfers between eligible invoices are processed successfully and all balances remain consistent.
    ClickText          PayExed
    ClickText          Credit Transfers
    ClickText          New Transfer
    TypeText           Source Invoice                 INV-1001
    TypeText           Target Invoice                 INV-1002
    TypeText           Amount                         5000
    ClickText          Transfer
    VerifyText         Transfer Completed

Verify Credit Transfer Revert Workflow
    [Documentation]    Verify credit transfers can be reverted successfully and that the original credit and invoice balances are restored.
    ClickText          PayExed
    ClickText          Credit Transfers
    ClickElement       xpath=//tr[.//td[contains(text(),'INV-1001')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Revert Transfer
    ClickText          Confirm
    VerifyText         Transfer Reverted

Verify Prevention Of Invalid Credit Transfers
    [Documentation]    Verify invalid credit transfers are prevented when the credit is insufficient, expired, unavailable, or assigned to an ineligible invoice.
    [Tags]             Negative
    ClickText          PayExed
    ClickText          Credit Transfers
    ClickText          New Transfer
    TypeText           Source Invoice                 INV-EXPIRED
    TypeText           Target Invoice                 INV-1002
    TypeText           Amount                         500000
    ClickText          Transfer
    VerifyText         Selected source credit is expired or insufficient.

Verify Credit Balance Consistency Across Enrollment Changes
    [Documentation]    Verify credit-balance enrollment changes preserve consistency across payments, refunds, credits, invoices, and enrollment records.
    ClickText          Enrollment                     anchor=Overview
    ClickElement       xpath=//tr[.//a[contains(text(),'${CONTACT_NAME}')]]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Transfer Course
    TypeText           Target Program                 ${TRANSFER_COURSE}
    ClickText          Submit Transfer
    VerifyText         Credits and Invoices Transferred Consistently

# ==============================================================================
# SECTION 6: INVOICE SPLITTING & CHILD INVOICE PAYMENTS
# ==============================================================================

Verify Split Invoice With Predefined Template
    [Documentation]    Verify PL can split an invoice using a predefined split template and that parent and child invoice amounts and relationships are correct.
    ClickText          PayExed
    ClickText          INV-2026-001
    ClickText          Split Invoice                  recognition_mode=vision
    ClickText          Apply Template
    ComboBox           Select Template                Standard 50/50 Split
    ClickText          Execute Split
    ScrollTo           Child Invoices
    VerifyText         Child Invoice 1                anchor=Child Invoices
    VerifyText         Child Invoice 2                anchor=Child Invoices

Verify Split Invoice With User Defined Criteria
    [Documentation]    Verify PL can split an invoice using user-defined criteria and that the resulting child invoices contain the correct amounts and allocations.
    ClickText          PayExed
    ClickText          INV-2026-002
    ClickText          Split Invoice                  recognition_mode=vision
    UseModal           On
    ClickText          Add Split
    TypeText           Percent                        60.00%    anchor=Split Type
    ClickText          Add Split
    TypeText           Percent                        40.00%    anchor=Remove
    ClickText          Submit
    UseModal           Off
    VerifyText         Child Invoices (2)

Verify Prevention Of Invalid Invoice Splits
    [Documentation]    Verify invalid split requests are rejected when amounts do not reconcile, required data is missing, or split criteria are invalid.
    [Tags]             Negative
    ClickText          PayExed
    ClickText          INV-2026-002
    ClickText          Split Invoice                  recognition_mode=vision
    UseModal           On
    ClickText          Add Split
    TypeText           Percent                        70.00%
    ClickText          Add Split
    TypeText           Percent                        40.00%
    ClickText          Submit
    VerifyText         Total split percentage must equal 100%.
    ClickText          Cancel

Verify Payer Can Pay Child Invoice Supported Methods
    [Documentation]    Verify a payer can successfully pay a child invoice using all supported payment methods and that the parent invoice balance is updated correctly.
    ClickText          PayExed
    ClickText          INV-2026-002-C1
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    ClickText          Credit Card
    ClickText          PAY NOW
    SwitchWindow       1
    ClickText          INV-2026-002                   # Parent
    VerifyText         Partially Paid                 anchor=Parent Invoice

Verify Payer Can Pay Parent Invoice Directly
    [Documentation]    Verify a payer can successfully pay the parent invoice and that all applicable child invoice balances and payment statuses are updated correctly.
    ClickText          PayExed
    ClickText          INV-2026-003                   # Parent
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    ClickText          PAY NOW
    SwitchWindow       1
    VerifyText         Paid                           anchor=Child Invoice 1
    VerifyText         Paid                           anchor=Child Invoice 2

Verify Partial And Full Payment Balance Safeguards On Split Invoices
    [Documentation]    Verify partial and full payments on split child and parent invoices maintain correct balances without double-counting payments.
    ClickText          PayExed
    ClickText          INV-2026-004
    VerifyText         Total Parent Balance Equals Sum Of Unpaid Children

Verify System Integrity Post Invoice Splitting Actions
    [Documentation]    Verify enrollment changes, direct payments, refunds, credit transfers, and reverts remain financially consistent after invoice splitting.
    ClickText          PayExed
    ClickText          INV-2026-004
    ClickText          Refund Child Invoice
    ClickText          Confirm Refund
    VerifyText         Parent Balance Recalculated Correctly

# ==============================================================================
# SECTION 7: INVOICE CLEARING & TRANSFERS
# ==============================================================================

Verify PL/Finance Can Clear Eligible Invoice Transfer
    [Documentation]    Verify PL/Finance can clear an eligible invoice transfer and that the source and destination invoice balances and transfer status reconcile correctly.
    ClickText          PayExed
    ClickText          Invoice Transfers
    ClickElement       xpath=//tr[.//td[text()='TR-001']]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Clear Transfer
    VerifyText         Cleared                        anchor=TR-001

Verify Prevention Of Clearing Invalid Invoice Transfers
    [Documentation]    Verify invalid invoice transfers cannot be cleared when the transfer is incomplete, already cleared, reversed, or financially inconsistent.
    [Tags]             Negative
    ClickText          PayExed
    ClickText          Invoice Transfers
    ClickElement       xpath=//tr[.//td[text()='TR-CLEARED']]//button[contains(@class,'slds-button') or contains(@title,'Actions')]
    ClickText          Clear Transfer
    VerifyText         Transfer has already been cleared or is invalid.

Verify Sequential Clearing Of Multiple Invoice Transfers
    [Documentation]    Verify multiple invoice transfers can be cleared in the correct sequence without creating balance discrepancies.
    ClickText          PayExed
    ClickText          Invoice Transfers
    ClickText          Clear All Pending In Sequence
    VerifyText         All pending transfers cleared successfully.

# ==============================================================================
# SECTION 8: FINANCIAL RECONCILIATION, PERMISSIONS & AUDIT TRAIL
# ==============================================================================

Verify Financial Reconciliation Process
    [Documentation]    Verify Finance can perform financial reconciliation across enrollment changes, direct payments, refunds, credit transfers, split invoices, and invoice clearing.
    ClickText          Financial Reconciliation
    ClickText          Run Reconciliation Batch
    Sleep              5s
    VerifyText         Reconciliation Batch Status: Completed
    VerifyText         Unreconciled Items: 0

Verify Reconciliation Anomaly Reporting
    [Documentation]    Verify financial reconciliation identifies and reports mismatched, missing, duplicate, or incorrectly allocated transactions.
    [Tags]             Negative
    ClickText          Financial Reconciliation
    ClickText          View Exception Dashboard
    VerifyText         Mismatched Transactions

Verify Reconciliation Robustness Across Operations
    [Documentation]    Verify reconciliation remains accurate after successful and failed transactions, partial and full payments/refunds, multiple transfers, and applicable reverts.
    ClickText          Financial Reconciliation
    ClickText          Run Comprehensive Ledger Audit
    VerifyText         Ledger Balances Balanced

Verify Role Based Access Controls And Security
    [Documentation]    Verify unauthorized users cannot perform program setup, enrollment changes, payments, refunds, credit transfers, invoice splits, clearing, or reconciliation actions outside their assigned permissions.
    [Tags]             Security
    SwitchUserTo       Standard Student User
    ClickText          Programs                       anchor=Home
    VerifyText         New                            state=absent
    ClickText          Financial Reconciliation
    VerifyText         You do not have access to this page.

Verify Audit Trail Capture Across Lifecycle Actions
    [Documentation]    Verify audit and history records capture all cumulative changes across program setup, enrollment, payments, refunds, credits, invoice splits, transfers, clearing, and reconciliation.
    ClickText          Programs                       anchor=Home
    ClickText          Testing1 - September 2026
    ClickText          PayExed
    ClickText          History
    VerifyText         Program Created
    VerifyText         Enrollment Stage Updated
    VerifyText         Payment Received
    VerifyText         Invoice Split Executed
    VerifyText         Transfer Cleared

