"""
Hii app - screen-size safety fixes. Run from the project root:
    python3 make_responsive.py
Safe to run more than once (already-fixed files are skipped).
"""
import re, sys

def rd(p): return open(p, encoding="utf-8", newline="").read()
def wr(p, s): open(p, "w", encoding="utf-8", newline="").write(s)
def ind(l): return l[:len(l) - len(l.lstrip())]
def eol(l): return l[len(l.rstrip("\r\n")):]

def close_idx(L, start, closer="),"):
    I = ind(L[start])
    for k in range(start + 1, len(L)):
        if L[k].rstrip("\r\n") == I + closer:
            return k
    sys.exit("  !! closing '%s' not found for: %s" % (closer, L[start].strip()))

def wrap(L, i, wrapper, extra_before_close=None):
    """Wrap the widget starting on line i ('X(' or 'child: X(') in `wrapper`."""
    j = close_idx(L, i)
    I, body = ind(L[i]), L[i].strip()
    prefix = "child: " if body.startswith("child: ") else ""
    L[i] = I + prefix + wrapper + "child: " + body[len(prefix):] + eol(L[i])
    if extra_before_close:
        for n, line in enumerate(extra_before_close):
            L.insert(j + n, I + "  " + line + eol(L[j]))
        j += len(extra_before_close)
    L[j] = I + "))," + eol(L[j])

MARK = "// screen-size-safety-fix"
changed = []

# ---------------------------------------------------------------- 1. main.dart
p = "lib/main.dart"; s = rd(p)
if "ResponsiveAppClamp(" in s:
    print("SKIP main.dart (already wired)")
else:
    a = "            debugShowCheckedModeBanner: false,"
    assert s.count(a) == 1, "main.dart anchor not found"
    nl = "\r\n" if "\r\n" in s else "\n"
    s = s.replace(a, a + nl +
        "            // Caps extreme system font sizes + keeps tablets phone-proportioned." + nl +
        "            builder: (context, child) =>" + nl +
        "                ResponsiveAppClamp(child: child ?? const SizedBox.shrink()),", 1)
    s = s.replace("import 'utilities/profile_completion_navigation.dart';",
                  "import 'utilities/profile_completion_navigation.dart';" + nl +
                  "import 'utilities/responsive_app_clamp.dart';", 1)
    assert "utilities/responsive_app_clamp.dart" in s, "main.dart import anchor not found"
    wr(p, s); changed.append(p)

# --------------------------------------------- 2. Reject / Send Invite / Accept bars
for p in ["lib/view/other/MySplashSection/VenuesSection/venuepages.dart",
          "lib/view/other/MySplashSection/MembersSection/member_liked_details.dart",
          "lib/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart"]:
    s = rd(p)
    if MARK in s or "action-bar-overflow-fix" in s:
        print("SKIP", p.split("/")[-1], "(action bar already fixed)"); continue
    L = s.splitlines(keepends=True)
    for label in ("'Reject'", "'Accept'"):
        i = next(k for k in range(len(L) - 1)
                 if L[k].strip() == "_buildDecisionButton(" and ("label: " + label) in L[k + 1])
        wrap(L, i, "Expanded(")
    t = next(k for k, l in enumerate(L) if "AppLanguage.sendInviteText[language]" in l
             and any("GestureDetector(" in L[m] for m in range(k - 40, k)))
    g = next(k for k in range(t, 0, -1) if L[k].strip() in ("GestureDetector(", "child: GestureDetector("))
    if "Expanded(" not in L[g - 1]:
        wrap(L, g, "Expanded(")
        for k in range(g, t):
            if L[k].strip() in ("width: size.width * 30 / 100,", "width: size.width * 29 / 100,"):
                del L[k]; t -= 1; break
    c = next(k for k in range(t, g, -1) if L[k].strip() == "child: Center(")
    wrap(L, c, "FittedBox(fit: BoxFit.scaleDown, ")
    m = next(k for k, l in enumerate(L) if l.strip().startswith("Widget _buildDecisionButton("))
    for k in range(m, m + 40):
        if "EdgeInsets.symmetric(horizontal: 18, vertical: 11)" in L[k]:
            L[k] = L[k].replace("horizontal: 18", "horizontal: 12")
        if L[k].strip() == "child: Row(":
            wrap(L, k, "FittedBox(fit: BoxFit.scaleDown, "); break
    if p.endswith("venuepages.dart"):  # matching right-hand gap
        a = next(k for k in range(len(L) - 1)
                 if "Expanded(child: _buildDecisionButton(" in L[k] and "label: 'Accept'" in L[k + 1])
        b = close_idx(L, a, ")),")
        if L[b + 1].strip() == "],":
            L.insert(b + 2, ind(L[b + 1]) + "SizedBox(width: size.width * 3 / 100)," + eol(L[b + 1]))
    s = "".join(L).replace("_fullActionBarWidthFactor = 0.85;", "_fullActionBarWidthFactor = 0.9;")
    s = s.replace("Widget _buildDecisionButton(", MARK + "\n  Widget _buildDecisionButton(", 1)
    wr(p, s); changed.append(p)

# ------------------------------------------ 3. Members list: long names / addresses
p = "lib/view/other/MySplashSection/MembersSection/Members.dart"; s = rd(p)
if MARK in s:
    print("SKIP Members.dart (already fixed)")
else:
    L = s.splitlines(keepends=True); n = 0
    k = 0
    while k < len(L) - 1:
        if L[k].strip() == "Text(" and L[k + 1].strip() in ("memberName.isEmpty", "memberAddress,"):
            lines = 1 if L[k + 1].strip() == "memberName.isEmpty" else 2
            wrap(L, k, "Flexible(", ["maxLines: %d," % lines, "overflow: TextOverflow.ellipsis,"]); n += 1
        k += 1
    assert n == 4, "expected 4 name/address texts in Members.dart, found %d" % n
    L.insert(0, MARK + eol(L[0]))
    wr(p, "".join(L)); changed.append(p)

# ------------------------------------ 4. Booking/receipt "label ... value" rows (5 screens)
for p in ["lib/view/other/MySplashSection/VenuesSection/venue_booking_details.dart",
          "lib/view/other/MySplashSection/VenuesSection/past_venue_screeen.dart",
          "lib/view/other/MySplashSection/EventSection/past_events_screen.dart",
          "lib/view/other/MySplashSection/EventSection/booked_view_details.dart",
          "lib/view/other/MySplashSection/EventSection/Liked/booked_event_details.dart"]:
    s = rd(p)
    if MARK in s:
        print("SKIP", p.split("/")[-1], "(already fixed)"); continue
    L = s.splitlines(keepends=True)
    d = next(k for k, l in enumerate(L) if l.strip().startswith("Widget detailsRow("))
    v = next(k for k in range(d, d + 45) if L[k].strip() == "value," and L[k - 1].strip() == "Text(")
    L.insert(v - 1, ind(L[v - 1]) + "const SizedBox(width: 12)," + eol(L[v - 1])); v += 1
    wrap(L, v - 1, "Flexible(", ["textAlign: TextAlign.end,"])
    L.insert(d, "  " + MARK + eol(L[d]))
    wr(p, "".join(L)); changed.append(p)

# ------------------------------------------------------------- 5. Chat top bar
p = "lib/view/other/chats/chat_message_screen.dart"; s = rd(p)
a = "SizedBox(width: size.width * 15 / 100),"
if a not in s:
    print("SKIP chat_message_screen.dart (already fixed)")
else:
    assert s.count(a) == 1
    s = s.replace(a, "const Spacer(), " + MARK, 1); wr(p, s); changed.append(p)

# ------------------------------------------- 6. Owl (AI assistant) above the nav bar
p = "lib/view/bottom navigation/home_Screen.dart"; s = rd(p)
nl = "\r\n" if "\r\n" in s else "\n"
old = nl.join([
    "          floatingActionButton: const Padding(",
    "            padding: EdgeInsets.only(bottom: 8),",
    "            child: AiAssistantLauncher(),",
    "          ),"])
if old not in s:
    print("SKIP home_Screen.dart (owl already moved)")
else:
    new = nl.join([
        "          // Lifted above the floating nav bar (app_footer.dart). " + MARK,
        "          floatingActionButton: ValueListenableBuilder<bool>(",
        "            valueListenable: footerVisibilityNotifier,",
        "            builder: (context, footerVisible, _) => Padding(",
        "              padding: EdgeInsets.only(",
        "                bottom: footerVisible",
        "                    ? MediaQuery.of(context).size.height * 8 / 100 + 12",
        "                    : 8,",
        "              ),",
        "              child: const AiAssistantLauncher(),",
        "            ),",
        "          ),"])
    s = s.replace(old, new, 1)
    if "utilities/app_constant.dart" not in s:
        i = s.index("import ")
        s = s[:i] + "import '../../utilities/app_constant.dart';" + nl + s[i:]
    wr(p, s); changed.append(p)

print("\nDone. Files changed:" if changed else "\nNothing to change - all fixes already applied.")
for c in changed: print("  -", c)
