
**** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Library    QWeb
Library    DateTime    # Required for timestamp generation
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome


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
    TypeText      Verification Code    11KLAYEG2L
    ClickText     Verify
    VerifyText    Home

Make Payments with different cards
    ClickText     Programs             anchor=Home
    ClickText     ACR-20260820-132926 - December 2026
    ClickText     PayExed              anchor=Enrollment
    ClickText     ACR-20260820-13-R6605
    Sleep         5s
    ClickElement                       xpath=//a[contains(@href,'pay')]
    SwitchWindow                       NEW
    ClickText                         Make Payment
    ClickText                        Payment Amount (USD)
    TypeText                        Payment Amount (USD)          100
    TypeText                        Card number                   ${Stripe_Credentials.Card Number}
    TypeText                        Expiration date               ${Stripe_Credentials.Exp Date}
    TypeText                        Security code                 ${Stripe_Credentials.CVC}
    ClickText                       PAY NOW
    IF    '${Stripe_Credentials.Expected Outcome}' == 'Success'
        VerifyText     Your payment was successful.    timeout=10s
    ELSE
        VerifyText     Your card was declined.         timeout=10s
    END

Cleanup Payment Window
    [Documentation]    Closes open payment window and resets state between iterations.
    CloseWindow
    CloseBrowser