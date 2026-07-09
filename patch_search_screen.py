import sys

path = "lib/view/bottom navigation/search_screen.dart"

with open(path, "r", encoding="utf-8", newline="") as f:
    content = f.read()

old1 = """                                                                    if (categoryList.isNotEmpty)
                                                                      Positioned(
                                                                        left: 10,
                                                                        top: 10,
                                                                        child: Row(
                                                                          children: categoryList.map((tag) {
                                                                            return Container(
                                                                              margin: const EdgeInsets.only(right: 6),
                                                                              padding: const EdgeInsets.symmetric(
                                                                                horizontal: 10,
                                                                                vertical: 5,
                                                                              ),
                                                                              decoration: _featuredTagDecoration(),
                                                                              child: Text(
                                                                                tag,
                                                                                style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: 10,
                                                                                  fontFamily: AppFont.fontFamily,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                        ),
                                                                      ),"""

new1 = """                                                                    if (categoryList.isNotEmpty)
                                                                      Positioned(
                                                                        left: 10,
                                                                        right: 10,
                                                                        top: 10,
                                                                        child: SingleChildScrollView(
                                                                          scrollDirection: Axis.horizontal,
                                                                          child: Row(
                                                                          children: categoryList.map((tag) {
                                                                            return Container(
                                                                              margin: const EdgeInsets.only(right: 6),
                                                                              padding: const EdgeInsets.symmetric(
                                                                                horizontal: 10,
                                                                                vertical: 5,
                                                                              ),
                                                                              decoration: _featuredTagDecoration(),
                                                                              child: Text(
                                                                                tag,
                                                                                style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: 10,
                                                                                  fontFamily: AppFont.fontFamily,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                          ),
                                                                        ),
                                                                      ),"""

old2 = """                                                                      if (categoryList.isNotEmpty)
                                                                        Positioned(
                                                                          left: 10,
                                                                          top: 10,
                                                                          child: Row(
                                                                            children: categoryList.map((tag) {
                                                                              return Container(
                                                                                margin: const EdgeInsets.only(right: 6),
                                                                                padding: const EdgeInsets.symmetric(
                                                                                  horizontal: 10,
                                                                                  vertical: 5,
                                                                                ),
                                                                                decoration: _featuredTagDecoration(),
                                                                                child: Text(
                                                                                  tag,
                                                                                  style: const TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 10,
                                                                                    fontFamily: AppFont.fontFamily,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }).toList(),
                                                                          ),
                                                                        ),"""

new2 = """                                                                      if (categoryList.isNotEmpty)
                                                                        Positioned(
                                                                          left: 10,
                                                                          right: 10,
                                                                          top: 10,
                                                                          child: SingleChildScrollView(
                                                                            scrollDirection: Axis.horizontal,
                                                                            child: Row(
                                                                            children: categoryList.map((tag) {
                                                                              return Container(
                                                                                margin: const EdgeInsets.only(right: 6),
                                                                                padding: const EdgeInsets.symmetric(
                                                                                  horizontal: 10,
                                                                                  vertical: 5,
                                                                                ),
                                                                                decoration: _featuredTagDecoration(),
                                                                                child: Text(
                                                                                  tag,
                                                                                  style: const TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 10,
                                                                                    fontFamily: AppFont.fontFamily,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }).toList(),
                                                                            ),
                                                                          ),
                                                                        ),"""

count1 = content.count(old1)
count2 = content.count(old2)
print(f"Match 1 (venue card tags) found: {count1} time(s)")
print(f"Match 2 (event card tags) found: {count2} time(s)")

if count1 != 1 or count2 != 1:
    print("⚠️  Expected exactly 1 match each - aborting, no changes made. Paste this output back to Claude.")
    sys.exit(1)

content = content.replace(old1, new1)
content = content.replace(old2, new2)

with open(path, "w", encoding="utf-8", newline="") as f:
    f.write(content)

print("✅ Patched successfully.")
