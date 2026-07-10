import plistlib

path = "ios/Runner/Info.plist"

with open(path, 'rb') as f:
    data = plistlib.load(f)

modes = data.get('UIBackgroundModes', [])

if 'remote-notification' not in modes:
    modes.append('remote-notification')
    data['UIBackgroundModes'] = modes
    with open(path, 'wb') as f:
        plistlib.dump(data, f)
    print("Added remote-notification to UIBackgroundModes")
else:
    print("Already present")