*** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Library    QWeb
Library    DateTime    # Required for timestamp generation
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome
Suite Teardown          Close All Browsers

*** Variables ***
${contact_name}    Navya Tanwar   
${ProgramStartDateOfDec}    12/01/2026
${search_term}    Acceptance: Tanwar


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
    TypeText      Verification Code    UQSF6RQX54
    ClickText     Verify
    VerifyText    Home
    ClickText     Programs             anchor=Home
    ClickText     ACR-20260820-132926 - December 2026                          
Verify Payment Remainder through PayExed
    ClickText       PayExed                        anchor=Enrollment
    # Click blank space on the participant row to select without opening link
    ClickElement       xpath=//tr[td[contains(.,'${contact_name}')]]/td[5]
    # 1. Switch to Activity tab
    ClickText          Activity                       anchor=Contact Highlights
Verify Activity Tab Functionality
    # Test Refresh and verify success toast notification
    ClickElement       xpath=//a[contains(text(),'Refresh') or contains(.,'Refresh')] | //button[contains(.,'Refresh')]
    VerifyText         Data refreshed successfully    timeout=10s

    # Test Search functionality
    TypeText           Search subject or body         ${search_term}
    PressKey           xpath=//input[contains(@placeholder,'Search subject or body')]    \13
    VerifyText         ${search_term}                 timeout=5s

    # Clear search input
    TypeText           Search subject or body         ${EMPTY}
    PressKey           xpath=//input[contains(@placeholder,'Search subject or body')]    \13

    # 5. Expand individual activity timeline items
    ClickElement       xpath=//span[contains(text(),'Payment -')]/ancestor::a | //div[contains(.,'Payment -')]//button
    VerifyText         Amount                         timeout=5s

    # 6. Test Collapse All / Expand All toggle
    ${is_collapse_present}=                           IsText    Collapse All    timeout=3s
    IF    ${is_collapse_present}
        ClickText      Collapse All
        VerifyText     Expand All                     timeout=5s
        ClickText      Expand All
    ELSE
        ClickText      Expand All
        VerifyText     Collapse All                   timeout=5s
    END