class_name MenuOptionArchipelago
extends MenuOptionNew

func ConnectToArchipelago() -> void:
	print("Would attempt connection with:\n\tServer Address: %s\n\tSlot Name: %s\n\tPassword: %s\n", %ServerAddressBox.text, %SlotNameBox.text, %PasswordBox.text)
	return
	#GameSettings.attemptConnection(%ServerAddressBox.text, %SlotNameBox.text, %PasswordBox.text)
