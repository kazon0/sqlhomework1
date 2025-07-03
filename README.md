# 过敏性疾病专病库管理系统 (Allergic Disease Management System)

AllerTrack（过敏追踪)过敏性疾病临床研究设计的全周期医疗数据管理系统，采用Swift 5语言和SwiftUI框架开发，基于MVVM架构实现数据与界面的高效分离。系统通过原生SQLite3数据库进行本地化数据存储，利用DatabaseManager.swift封装核心数据库操作，支持患者临床信息、流行病学数据、随访记录及生物样本的增删查改（CRUD）等完整管理功能。
系统采用模块化设计，包含数据模型层（Models）、视图层（Views）和数据库管理层，并配备标准Xcode资源配置（.xcassets）和物理数据库文件（allergy.db）。其特色在于专病库的精细化设计，提供完整的ER图和表结构方案，确保数据管理的规范性和可扩展性。系统适用于临床数据采集、科研分析及教学演示，并附带详实的开发文档和课程设计报告，既满足实际医疗场景需求，也适合作为数据库系统开发的范例项目。

![WechatIMG340](https://github.com/user-attachments/assets/69372c16-8598-448f-a030-b9bdfc72c035)

##  技术栈

- **语言**：Swift 5
- **数据库**：SQLite3（使用系统原生 `sqlite3` C 接口）
- **架构**：MVVM 简化结构
- **界面框架**：SwiftUI
- **平台**：iOS

##  项目结构

```plaintext
AllergicDiseaseSystem/
├── Sources/
│   ├── DatabaseManager.swift      # SQLite3 封装操作类
│   ├── Models/                    # 数据模型定义（Patient, Diagnosis 等）
│   ├── Views/                     # 各模块界面（列表、表单）
│   ├── Resources/                 # 图标、样本数据等资源
│   └── ContentView.swift          # 应用入口（功能导航页）
├── clinic.sqlite                  # SQLite 数据库文件
├── README.md                      # 项目说明文档
└── Report/                        # 课程报告材料（PDF / Word）
