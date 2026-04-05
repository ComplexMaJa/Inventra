# 📦 Inventra 
**Premium Inventory Management Dashboard**

Inventra is a modern, responsive, and completely standalone local CRUD (Create, Read, Update, Delete) dashboard built natively in **Flutter**. It eschews generic list setups for a fully-featured, animated admin experience completely capable of cross-platform database interactions.

---

### ✨ Core Features
- **Persisted Media Logic**: Replaces standard temporary file-path routing with dynamic Base64 serialization allowing images uploaded during active browser caching entirely persistent capability post page refreshes.
- **Smart Audit Dashboard**: Features an active overview header calculating Total Inventory Values and flagging critically short products (Stock < 5) wrapped tightly within an interactive visual structure allowing direct 'Tap-To-Filter' parameters. 
- **Compound Searching & Sorting**: Pairs simple text-mask field routing directly against a dynamic dropdown matrix to apply structural ordering (A-Z, Low-to-High) immediately recursively.
- **Fluid Micro-Animations**: Prioritizes physical UX feedback by avoiding rigid routing. Incorporates implicit scale bounds, nested `FadeTransition` page hopping, customized Empty states and Glassmorphism layouts. 
- **Universal Local Integrity**: Leverages structural `sqflite` databases heavily backed by `sqflite_common_ffi_web` ensuring no data degradation between pure-web scaling and Android emulation bounds.

---

### 💻 Technologies Stack

* **[Flutter SDK](https://flutter.dev/)**
* **Database**: `sqflite` + `sqflite_common_ffi_web`
* **Local Caching**: `shared_preferences`
* **Media Parsing**: `image_picker`

---

### 🚀 Getting Started

1. **Clone down the repository:**
   ```bash
   git clone https://github.com/yourusername/inventra.git
   ```

2. **Acquire target dependencies:**
   ```bash
   flutter pub get
   ```

3. **Start up the rendering engine:**
   *(Run your respective target parameter)*
   ```bash
   flutter run -d web-server  # Fastest execution for web deployment
   # OR
   flutter run                # Standard mobile execution
   ```

*(Default hardcoded authentication context for dashboard access)*
> **Username:** `admin`  
> **Password:** `1234`

---

*Designed and orchestrated as a highly-polished template constraint for modern assignment and application standards.*
