import plistlib

path = "ios/Runner/Info.plist"

with open(path, 'rb') as f:
    data = plistlib.load(f)

scheme = "app-1-337909267770-ios-9bf10e618cd62c9ae4a403"

url_types = data.get('CFBundleURLTypes', [])

already_present = any(scheme in t.get('CFBundleURLSchemes', []) for t in url_types)

if not already_present:
    url_types.append({
        'CFBundleTypeRole': 'Editor',
        'CFBundleURLSchemes': [scheme]
    })
    data['CFBundleURLTypes'] = url_types
    with open(path, 'wb') as f:
        plistlib.dump(data, f)
    print(f"Added URL scheme: {scheme}")
else:
    print("URL scheme already present, no changes made.")