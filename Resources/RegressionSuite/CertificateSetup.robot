**** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Library    QWeb
Library    DateTime    # Required for timestamp generation
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome

*** Variables ***
# --- e-Certificate Setup Fields ---
${CERT_FIRST_LINE}              Presents to
${CERT_SECOND_LINE}             this Certificate of Completion for the
${CERT_THIRD_LINE}              LEAD Cohort 2025

${PARTNER_NAME}                 National Football League
${PARTNER_TITLE}                Chief Executive Officer
${PARTNER_SIG_IMAGE}            NFL_CEO_Signature

# --- Partner & Other Fields ---
${PROGRAM_SUFFIX}               LEAD-2025
${BUTTON_LABEL}                 Review Program Outcomes
${EXEC_ED_LOGO}                 Stanford_GSB_ExecEd_Logo
${TEXT_BETWEEN_LOGOS}           in partnership with
${PARTNER_LOGO}                 NFL_Partner_Log

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
    TypeText      Verification Code    10VDRWLTDR
    ClickText     Verify
    VerifyText    Home
    ClickText     Programs             anchor=Home

Verify user Can Create A Valid Program
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

Populate Certificate Setup and Signature Sections
    [Documentation]    Navigates to the Certificate sub-tab and populates editable fields, leaving auto-populated program names and dates untouched.

    # 1. Navigate to Program Details -> Certificate Sub-tab
    ClickText        Details                         anchor=Content
    ClickText        Certificate                     anchor=Participant Site

    # 2. Populate non-auto-populated e-Certificate Setup Section
    # (Leaving Certificate Program Name, Certificate Program Name 2nd Line, and Program Start and End Dates as auto-populated)
    ClickText        Edit Certificate Type
    ClickText        --None--                        anchor=Certificate Type
    ClickText        Certificate of Completion          


    # 4. Populate Logos Section Fields
    ClickText        --None--                        anchor=Exec Ed Logo (BCdiploma)
    ClickText        ExecEdLogo
    TypeText         Partner Logo (BCdiploma)        ${PARTNER_LOGO}

    
    # 6. Save Form and Verify Submission
    ClickText        Save                            timeout=20s
    