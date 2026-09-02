*** Settings ***
Documentation     Data-driven Stripe payment test suite iterating over all datasets.
Library           QForce
Library           QWeb
Library           DateTime
Library    DataDriver    reader_class=stripe_credential_4    name=Stripe Credentials.csv
Test Setup        Login To Salesforce And Open Payment Page
Test Teardown     Close Current Browser Session


*** Variables ***
${PROGRAM_NAME}       ACR-20260820-132926 - December 2026
${INVOICE_ID}         ACR-20260820-13-R6605
${PAYMENT_AMOUNT}     100


*** Test Cases ***
#Execute Stripe Payments Across All Datasets
    # Direct call removes the QEditor syntax error
 #   Perform Stripe Payment    ${Stripe_Credentials.Card Number}    ${Stripe_Credentials.Exp Date}    ${Stripe_Credentials.CVC}    ${Stripe_Credentials.Expected Outcome}


*** Keywords ***
Login To Salesforce And Open Payment Page
    OpenBrowser        ${login_url}        chrome
    VerifyText         Salesforce login
    TypeText           Username            ${username_Admin}
    ClickText          Log In to Sandbox
    VerifyText         Password
    TypeSecret         Password            ${password_Admin}
    ClickText          Log In to Sandbox
    VerifyText         Verify Your Identity
    TypeText           Verification Code   11KLAYEG2L
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
    [Arguments]        ${card_num}    ${exp_date}    ${cvc}    ${expected_outcome}
    
    ClickText          Payment Amount (USD)
    TypeText           Payment Amount (USD)    ${PAYMENT_AMOUNT}
    TypeText           Card number             ${card_num}
    TypeText           Expiration date         ${exp_date}
    TypeText           Security code           ${cvc}
    ClickText          PAY NOW

    IF    '${expected_outcome}' == 'Success'
        VerifyText     Your payment was successful.    timeout=10s
    ELSE
        VerifyText     Your card was declined.         timeout=10s
    END

Close Current Browser Session
    CloseWindow
    SwitchWindow       MAIN
    CloseBrowser