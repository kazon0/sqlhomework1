# 过敏性疾病专病库管理系统 (Allergic Disease Management System)

 本项目为一款使用 **Swift + 原生 SQLite3** 开发的本地化数据库管理系统，旨在对过敏性疾病患者的临床信息、流行病学数据、随访记录以及生物样本进行结构化存储和统一管理。系统以患者为核心，围绕其医疗全过程提供信息支持，适用于课题研究与临床数据管理场景。

##  项目背景

该系统为《数据库课程设计》项目成果，要求围绕特定专病数据库展开结构建模与程序开发。项目重点在于数据库设计（ER 图、表结构）、数据管理功能实现（增删查改）、文档撰写（说明系统结构与开发过程），并进行系统演示。

##  技术栈

- **语言**：Swift 5
- **数据库**：SQLite3（使用系统原生 `sqlite3` C 接口）
- **架构**：MVVM 简化结构
- **界面框架**：SwiftUI
- **平台**：macOS / iOS

##  项目结构

```plaintext
AllergicDiseaseSystem/
├── Sources/
│   ├── DatabaseManager.swift      # SQLite3 封装操作类
│   ├── Models/                    # 数据模型定义（Patient, Diagnosis 等）
│   ├── Views/                     # 各模块界面（列表、表单）
│   ├── Resources/                 # 图标、样本数据等资源
│   └── ContentView.swift          # 应用入口（功能导航页）
├── allergy.db                     # SQLite 数据库文件
├── README.md                      # 项目说明文档
└── Report/                        # 课程报告材料（PDF / Word）
