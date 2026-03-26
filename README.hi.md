<p align="center">
  <a href="README.ja.md">日本語</a> | <a href="README.zh.md">中文</a> | <a href="README.es.md">Español</a> | <a href="README.fr.md">Français</a> | <a href="README.md">English</a> | <a href="README.it.md">Italiano</a> | <a href="README.pt-BR.md">Português (BR)</a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/mcp-tool-shop-org/brand/main/logos/star-freight-client/readme.png" width="400" alt="Star Freight Client" />
</p>

<p align="center">
  <a href="https://github.com/mcp-tool-shop-org/star-freight-client/actions"><img src="https://github.com/mcp-tool-shop-org/star-freight-client/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License" /></a>
  <a href="https://mcp-tool-shop-org.github.io/star-freight-client/"><img src="https://img.shields.io/badge/docs-landing%20page-brightgreen" alt="Landing Page" /></a>
</p>

Godot 4.6 का ग्राफिकल क्लाइंट, [स्टार फ्रेट](https://github.com/mcp-tool-shop-org/star-freight) नामक स्पेस मर्चेंट आरपीजी गेम के लिए। यह पिक्सेल स्प्राइट पैक्स का उपयोग करके क्रू, प्राणियों और दुश्मनों को प्रदर्शित करता है, जो [स्प्राइट फाउंड्री](https://github.com/mcp-tool-shop-org/star-freight-foundry) पाइपलाइन से लिए गए हैं।

पायथन इंजन ही मुख्य स्रोत है। यह क्लाइंट एक रेंडरिंग सतह है - यह इंजन द्वारा JSON-RPC के माध्यम से stdio पर भेजे गए डेटा को प्रदर्शित करता है।

> पायथन इंजन पैकेज वर्तमान में 'पोर्टलाइट' के रूप में है, ताकि निरंतरता बनी रहे।
> उपयोगकर्ता के लिए उत्पाद का नाम **स्टार फ्रेट** है।
> यदि वांछित हो, तो नेमस्पेस का परिवर्तन बाद में एक अलग प्रक्रिया के माध्यम से किया जाएगा।

## आर्किटेक्चर

```
star-freight (Python)          star-freight-client (Godot 4.6)
┌──────────────────┐           ┌──────────────────────────┐
│ portlight.engine │──JSON-RPC─│ engine_bridge.gd         │
│ portlight.rpc    │  (stdio)  │ pack_loader.gd           │
│ portlight.content│           │ character_node.gd        │
└──────────────────┘           │ scenes/roster.tscn       │
                               │ assets/characters/       │
                               └──────────────────────────┘
```

- **इंजन ब्रिज**: stdio पर JSON-RPC 2.0। Godot, `starfreight rpc` को एक सबप्रोसेस के रूप में चलाता है।
- **पैक लोडर**: इम्पोर्ट किए गए स्प्राइट पैक्स से `manifest.json` फ़ाइल को पढ़ता है। कैनवस टेक्सचर बनाता है (एल्बिडो + नॉर्मल)।
- **कैरेक्टर नोड**: स्प्राइट2D रैपर, जिसमें 8 दिशाओं में घूमने और नॉर्मल मैप लाइटिंग की सुविधा है।

## आवश्यकताएं

- [Godot 4.6.1](https://godotengine.org/download) (मानक बिल्ड, .NET नहीं)
- Python 3.11+ जिसमें `star-freight` स्थापित हो
- विंडोज 11 (मुख्य विकास प्लेटफ़ॉर्म)

## शुरुआत कैसे करें

1. इस प्रोजेक्ट को Godot 4.6 में खोलें।
2. F5 दबाकर गेम चलाएं - रोस्टर सीन 3 कैरेक्टर पैक्स लोड करेगा।
3. नियंत्रण:
- **A/D** या तीर कुंजियाँ: चयनित कैरेक्टर को घुमाएं।
- **Tab**: कैरेक्टरों के बीच स्विच करें।
- **Space**: सभी कैरेक्टरों को घुमाएं।
- **B**: पायथन इंजन से कनेक्ट करें (इसमें `starfreight` स्थापित होना चाहिए)।
- **Esc**: गेम से बाहर निकलें।

## स्प्राइट पैक्स इम्पोर्ट करना

पैक्स को `assets/characters/` में रखा जाता है। फाउंड्री से इम्पोर्ट करने के लिए:

```bash
python scripts/import_packs.py                            # all 20 subjects
python scripts/import_packs.py --subjects sera_vale,thal  # specific subjects
```

## RPC विधियाँ

| विधि | पैरामीटर | रिटर्न |
|--------|--------|---------|
| `ping` | — | `{status, version}` |
| `get_roster` | — | `{crew: [...], count}` |
| `get_crew_member` | `{id}` | क्रू सदस्य का डेटा |
| `get_campaign` | — | कैंपेन का सारांश |
| `shutdown` | — | `{status}` |

## एक्सपोर्ट कॉन्ट्रैक्ट

स्प्राइट पैक्स, फ्रोजन फाउंड्री एक्सपोर्ट कॉन्ट्रैक्ट (v1.0.0) का पालन करते हैं:

- 8 दिशाएँ: सामने, सामने-बाएं, बाएं, पीछे-बाएं, पीछे, पीछे-दाएं, दाएं, सामने-दाएं
- 3 परतें: एल्बिडो, नॉर्मल, डेप्थ (सभी 48x48 पारदर्शी PNG)
- पिवट: केंद्र-नीचे
- मैनिफेस्ट: `manifest.json` जिसमें प्रत्येक फ़ाइल के लिए SHA-256 चेकसम होते हैं।

## सत्यापन

```bash
bash verify.sh
```

यह प्रोजेक्ट संरचना, एसेट पैक मैनिफेस्ट (JSON + स्कीमा संस्करण), GDScript की वैधता और सीन संदर्भों की जांच करता है।

## सुरक्षा और विश्वास

यह क्लाइंट **केवल स्थानीय रूप से** काम करता है:

- **डेटा जिस पर एक्सेस होता है**: स्थानीय PNG स्प्राइट फ़ाइलें (केवल पढ़ने के लिए), JSON मैनिफेस्ट (केवल पढ़ने के लिए), स्थानीय पायथन सबप्रोसेस को JSON-RPC संदेश।
- **डेटा जिस पर एक्सेस नहीं होता है**: कोई क्लाउड सेवाएं नहीं, कोई उपयोगकर्ता खाते नहीं, कोई नेटवर्क आउटगोइंग नहीं।
- कोई भी टेलीमेट्री एकत्र या भेजा नहीं जाता है।
- कोई भी सीक्रेट पढ़ा, संग्रहीत या प्रसारित नहीं किया जाता है।
- **सबप्रोसेस**: `starfreight rpc` को stdio के माध्यम से एक स्थानीय चाइल्ड प्रोसेस के रूप में शुरू करता है।

पूर्ण सुरक्षा नीति के लिए [SECURITY.md](SECURITY.md) देखें।

## लाइसेंस

MIT

[MCP Tool Shop](https://mcp-tool-shop.github.io/) द्वारा बनाया गया।
