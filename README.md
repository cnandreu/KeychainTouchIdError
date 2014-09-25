## Problem with Touch ID with PIN fallback

We are working on an application where we use Touch ID to read a secret from the keychain. 

We have found that when you read from the keychain immediately after a previous read, the read will return the string value the second time if a PIN code is used to read the secret. 

Below are some scenarios using KeychainTouchIdError the demo application. **These must be executed on a real device running iOS 8 with a touch id sensor.** All the scenarios work as expected when using the simulator.

### Scenario 1 (working):

1. Store value in keychain protected by `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`.
2. Read from keychain, use fingerprint to unlock.
3. No delay.
4. Read from keychain, use fingerprint or PIN to unlock.

### Scenario 2 (broken on devices):

1. Store value in keychain protected by `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`.
2. Read from keychain, use PIN to unlock.
3. No delay.
4. Read from keychain. When using a device the touch ID dialog is not presented and a null string is returned from the keychain. However, when using the simulator, the value stored in the keychain is correctly retrieved.

### Scenario 3 (working):

1. Store value in keychain protected by `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`.
2. Read from keychain, use PIN to unlock.
3. Wait 500ms.
4. Read from keychain. The user is presented a dialog and can read the secret again after using their fingerprint or PIN.

### Buttons available

* **Save** - Write a secret to the keychain protected by `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`.
* **Read** - Reads a secret from the keychain.
* **Remove** - Remove the secret from the keychain.
* **Quick** - Used to perform scenario 1 and 2.
* **Quick with Delay** - Used to perform scenario 3.

### Code 

* All the relevant code is available here: `KeychainTouchIdError/ViewController.m`.

### Comments

Our best guess is that the animation for the PIN unlock, which is a swipe down and lasts for about 250ms, is interfering with the second read. There is no animation when unlocking with a fingerprint. This is just a guess though.

Any ideas as to why we are running into a problem with Scenario 2? Is there anything that needs to be done to wait for the keychain to be ‘readable’ again?