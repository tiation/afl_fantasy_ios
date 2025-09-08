tell application "QuickTime Player"
	-- Start a new screen recording
	set screenRecording to new screen recording
	delay 1
	
	-- Start recording
	tell screenRecording
		start
	end tell
	
	-- Switch to Simulator and run demo
	tell application "Simulator"
		activate
	end tell
	
	-- Record for 30 seconds
	delay 30
	
	-- Stop recording
	tell screenRecording
		stop
		
		-- Save the recording
		save screenRecording in ((path to desktop folder as text) & "demo.mov")
	end tell
	
	quit
end tell
