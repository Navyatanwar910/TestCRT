*** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome
Suite Teardown          Close All Browsers

*** Test Cases ***
Verify login as system Admin and through setup as Finance user
    [Documentation]    User logs in salesforce.

    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    BO4DCHYK5U
    ClickText     Verify
    VerifyText    Home
    ClickText    Setup
    ClickText    Opens in a new tab
    SwitchWindow    NEW
    ClickText    Operations User
    ClickText    Login
    ClickText    Programs
    
Verify CoreTech/Finance can create a valid program with all mandatory setup data and that the program is available for downstream enrollment and financial processing.
    [Documentation]    Validates successful creation of a Program record using mandatory fields and exactly 25-char acronym.
  # 1. Navigate to the Program Custom Object
   ClickText          Programs
       ClickText          New
   ClickText          Open Enrollment
   ClickText          Next
  # 2. Populate text fields
   TypeText           Program Name                   Executive Leadership Cohort 2028
   TypeText           Acronym                        Testing1
   TypeText           Root Label                     EXEC-LEAD
  
  # 3. Handle Dates
   TypeText           Start Date                     09/01/2026
   TypeText           End Date                       08/31/2027
   TypeText           Program Fee                    200000

  # 4. Handle Picklists & Verification of Default Flags
   DropDown    Acceptance Criteria    Application/Admission
   DropDown    Program Status    Confirmed 

  # 5. Save and Confirm Formulations
   ClickText          Save                   timeout=20s      
   VerifyText         The Program was successfully created!
   ClickText          Finish
   VerifyText         Testing1 - September 2026   
Verify program creation is prevented when mandatory fields are missing, invalid, duplicate, or inconsistent.
    [Documentation]    Validates that a validation rule or field constraint fires when the acronym is too long
    [Tags]             Negative
  
   ClickElement       xpath=//a[@title='New']
   VerifyText         New Program                    anchor=Cancel
   ClickText          Open Enrollment
   ClickText          Next
  # Populate fields with an invalid 26 character acronym
   TypeText           Program Name                   Invalid Acronym Test
   TypeText           Acronym                ${INVALID_ACRONYM}
   VerifyText         Acronym length should not exceed 25 characters
   TypeText           Root Label                     INVALID-TEST
   TypeText           Start Date                     09/01/2026
   TypeText           End Date                       08/31/2027
   TypeText           Program Fee                    200000
   DropDown           Acceptance Criteria            Application/Admission
   DropDown           Program Status                 Confirmed
  # Attempt to Save
   ClickText          Save                          
  
  # Assert UI validation message appears
   VerifyText         Acronym length should not exceed 25 characters
   ClickText          Cancel

    ClickText     Programs             anchor=Home
    ClickElement       xpath=//a[@title='New']
    VerifyText         New Program                    anchor=Cancel
    ClickText          Open Enrollment
    ClickText          Next
    TypeText           Root Label                     INVALID-TEST
    TypeText           Start Date                     08/06/2026
    TypeText           End Date                       08/09/2026
    TypeText           Program Fee                    200000
    DropDown           Acceptance Criteria            Application/Admission
    DropDown           Program Status                 Confirmed  
                            
    VerifyText         Complete this field.
    ClickText          Save                        anchor=Previous
  # Assert UI validation message appears
    VerifyText         Please enter some valid input. Input is not optional.
    ClickText          Cancel

    ClickText     Programs             anchor=Home
    ClickElement       xpath=//a[@title='New']
    VerifyText         New Program                    anchor=Cancel
    ClickText          Open Enrollment
    ClickText          Next
    TypeText           Program Name                   Valid Acronym Test
    TypeText           Acronym                ${VALID_ACRONYM}
    TypeText           Root Label                     INVALID-TEST
    TypeText           Start Date                     08/06/2026
    TypeText           End Date                       08/06/2026
    TypeText           Program Fee                    200000
    DropDown           Acceptance Criteria            Application/Admission
    DropDown           Program Status                 Confirmed  
                            
    ClickText          Save                        anchor=Previous
  # Assert UI validation message appears
    VerifyText         Program Start Date should be greater than Program End Date.
    VerifyText         End Date is required and must be after Start Date.
    ClickText          Cancel
    ClickText     Programs             anchor=Home
    ClickElement       xpath=//a[@title='New']
    VerifyText         New Program                    anchor=Cancel
    ClickText          Open Enrollment
    ClickText          Next
    TypeText           Program Name                   Valid Acronym Test
    TypeText           Acronym                ${VALID_ACRONYM}
    TypeText           Root Label                     INVALID-TEST
    TypeText           Start Date                     08/06/2026
    TypeText           End Date                       08/06/2026
    TypeText           Program Fee                    200000
    DropDown           Acceptance Criteria            Application/Admission
    DropDown           Program Status                 Confirmed  
                            
    ClickText          Save                        anchor=Previous
  # Assert UI validation message appears
    VerifyText         A Program with acronym "ABCDFRGT123456BGRTiqn21" already exists in this fiscal year. Please use a different acronym or choose a start date in a different fiscal year.
    ClickText          Previous                     anchor=Finish

Verify PL can make a valid enrollment change without payment and that enrollment status and program records update correctly.

Verify PL can revert an enrollment change without payment and that all related records return to their previous valid state.

Verify invalid enrollment changes are rejected when participant, program, stage, or prerequisite data is invalid.

Verify Participant/Payer can make a successful full direct payment and that the invoice, payment, balance, and enrollment status update correctly.

Verify Participant/Payer can make a successful partial direct payment and that the remaining balance is calculated correctly.

Verify all supported direct payment methods process successfully and update the invoice and payment status correctly.

Verify failed, declined, cancelled, or invalid direct payments do not incorrectly update invoice or enrollment financial status.

Verify duplicate direct payments are prevented or handled without creating duplicate financial transactions.

Verify PL/Finance can change an enrollment after full direct payment and that all related financial records remain consistent.

Verify PL/Finance can change an enrollment after partial direct payment and that the outstanding amount is recalculated correctly.

Verify PL/Finance can process a full online refund for an enrollment change and that the payment, invoice, balance, and enrollment records are reconciled.

Verify PL/Finance can process a partial online refund and that only the eligible amount is refunded and the remaining payment balance is correct.

Verify PL/Finance can process a full manual refund and that the refund and invoice records are updated correctly.

Verify PL/Finance can process a partial manual refund and that financial balances remain consistent.

Verify enrollment changes involving direct payment can be reverted and that all payment, refund, invoice, and enrollment records return to the expected state.

Verify invalid, duplicate, excessive, or unsupported refunds are rejected without corrupting financial balances.

Verify PL/Finance can apply a full available credit balance to an eligible enrollment or invoice and that the credit balance and invoice balance update correctly.

Verify PL/Finance can apply a partial credit balance and that the remaining credit and invoice balance are calculated correctly.

Verify multiple credit transfers between eligible invoices are processed successfully and all balances remain consistent.

Verify credit transfers can be reverted successfully and that the original credit and invoice balances are restored.

Verify invalid credit transfers are prevented when the credit is insufficient, expired, unavailable, or assigned to an ineligible invoice.

Verify credit-balance enrollment changes preserve consistency across payments, refunds, credits, invoices, and enrollment records.

Verify PL can split an invoice using a predefined split template and that parent and child invoice amounts and relationships are correct.

Verify PL can split an invoice using user-defined criteria and that the resulting child invoices contain the correct amounts and allocations.

Verify invalid split requests are rejected when amounts do not reconcile, required data is missing, or split criteria are invalid.

Verify a payer can successfully pay a child invoice using all supported payment methods and that the parent invoice balance is updated correctly.

Verify a payer can successfully pay the parent invoice and that all applicable child invoice balances and payment statuses are updated correctly.

Verify partial and full payments on split child and parent invoices maintain correct balances without double-counting payments.

Verify enrollment changes, direct payments, refunds, credit transfers, and reverts remain financially consistent after invoice splitting.

Verify PL/Finance can clear an eligible invoice transfer and that the source and destination invoice balances and transfer status reconcile correctly.

Verify invalid invoice transfers cannot be cleared when the transfer is incomplete, already cleared, reversed, or financially inconsistent.

Verify multiple invoice transfers can be cleared in the correct sequence without creating balance discrepancies.

Verify Finance can perform financial reconciliation across enrollment changes, direct payments, refunds, credit transfers, split invoices, and invoice clearing.

Verify financial reconciliation identifies and reports mismatched, missing, duplicate, or incorrectly allocated transactions.

Verify reconciliation remains accurate after successful and failed transactions, partial and full payments/refunds, multiple transfers, and applicable reverts.

Verify unauthorized users cannot perform program setup, enrollment changes, payments, refunds, credit transfers, invoice splits, clearing, or reconciliation actions outside their assigned permissions.

Verify audit and history records capture all cumulative changes across program setup, enrollment, payments, refunds, credits, invoice splits, transfers, clearing, and reconciliation.

Verify the complete cumulative journey from program setup through enrollment, direct payment, enrollment change, refund, credit transfer, invoice split, invoice clearing, and financial reconciliation maintains consistent data across all dependent records.