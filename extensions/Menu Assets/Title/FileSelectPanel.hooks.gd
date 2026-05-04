extends Object

func SetFileInfo(chain: ModLoaderHookChain, data: Dictionary):
	chain.execute_next([data])
	if data.is_empty(): return
	if data.has("SaveData"):
		data = data.SaveData
		if data.is_empty(): return
	if(data.has("archipelagoEnabled")):

		var reference = chain.reference_object as FileSelectPanel
		var gearCounter = reference.find_child("FileGear")
		var shackleCounter = reference.find_child("FileGearDark")
		var shackleIcon = reference.find_child("IconGearDark")
		gearCounter.text = str(int(data["archipelagoData"]["gearCount"]))
		if(data["archipelagoData"]["shackleCount"] > 0):
			shackleCounter.text = str(int(data["archipelagoData"]["shackleCount"]))
			shackleCounter.visible = true
			shackleIcon.visible = true
