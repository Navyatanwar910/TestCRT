
*** Settings ***
Documentation     Data-driven Stripe payment test suite.
Library           QForce
Library           QWeb
Library           DateTime

Test Setup        Login And Navigate To Payment Page
Test Teardown     Cleanup Payment Window

*** Variables ***
${login_url}          https://gsbexeced--full.sandbox.lightning.force.com
${username_Admin}     your_admin_username
${password_Admin}     your_admin_password
${PROGRAM_NAME}       ACR-20260820-132926 - December 2026
${INVOICE_ID}         ACR-20260820-13-R6605
${PAYMENT_AMOUNT}     100

*** Test Cases ***
Execute Stripe Payment
    Perform Stripe Payment    ${Stripe_Credentials.Card Number}    ${Stripe_Credentials.Exp Date}    ${Stripe_Credentials.CVC}    ${Stripe_Credentials.Expected Response}


*** Keywords ***
Login And Navigate To Payment Page
    OpenBrowser        ${login_url}        chrome
    VerifyText         Salesforce login
    TypeText           Username            ${username_Admin}
    ClickText          Log In to Sandbox
    VerifyText         Password
    TypeSecret         Password            ${password_Admin}
    ClickText          Log In to Sandbox
    VerifyText         Verify Your Identity
    TypeText           Verification Code   MTQGAWBDPC
    ClickText          Verify
    VerifyText         Home
    ClickText          Programs            anchor=Home
    ClickText          ${PROGRAM_NAME}
    ClickText          PayExed             anchor=Enrollment
    ClickText          ${INVOICE_ID}
    Sleep              5s
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    VerifyText         Make Payment

Perform Stripe Payment
    [Arguments]        ${card_num}    ${exp_date}    ${cvc}    ${expected_response}
    
    ClickText          Payment Amount (USD)
    TypeText           Payment Amount (USD)    ${PAYMENT_AMOUNT}
    TypeText           Card number             ${card_num}
    TypeText           Expiration date         ${exp_date}
    TypeText           Security code           ${cvc}
    ClickText          PAY NOW

    IF    '${expected_response}' == 'Success' or '${expected_response}' == 'Payment Successful'
        VerifyText     Your payment was successful.    timeout=10s
    ELSE
        VerifyText     Your card was declined.         timeout=10s
    END

Cleanup Payment Window
    CloseWindow
    SwitchWindow       MAIN
    CloseBrowser