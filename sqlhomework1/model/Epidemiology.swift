//
//  Epidemiology.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//


import Foundation

struct EpidemiologyMain: Identifiable {
    var id: Int32 { patientId }
    let patientId: Int32
    let investigationDate: String   // 调查时间
    let patientName: String
    let gender: String
    let age: Int
    let residenceType: String       // 居住地类型（城市/农村）
    let residenceYears: Int         // 居住时长（年）
    let address: String
    let height: Double
    let weight: Double
    let hasAllergyHistory: Bool     // 既往过敏史：有无
    let allergyDiseases: String     // 具体疾病名称，如“过敏性鼻炎，支气管哮喘”
    let currentDiagnoses: String    // 本次调查疾病诊断名称
    let investigatorName: String    // 医疗调查者姓名
    let investigatorTitle: String   // 职称（住院医师等）
}

struct ResidenceInfo {
    let patientId: Int32
    let houseType: String
    let buildingMaterial: String
    let ventilationFrequency: String
    let acUsageSeason: String
    let acFrequency: String
    let acTemperatureSetting: String
    let acMode: String
    let acFilterCleaningFrequency: String
    let heatingUsageFrequency: String
    let roomTemperatureRange: String
    let hasCarpet: Bool
    let hasStuffedToys: Bool
}

struct AllergenLifestyle {
    let patientId: Int32
    let pm25Concentration: Double        // PM2.5家庭室内年均浓度 (g/m³)
    let pollenTypes: String              // 花粉种类及浓度，文本格式描述
    let formaldehydeConcentration: Double  // 甲醛浓度 (mg/m³)
    let formaldehydeTestDate: String    // 甲醛检测时间
    let dustMiteConcentration: Double   // 尘螨浓度 (单位: 个/g灰尘)
    let otherAllergens: String           // 其他过敏原说明（霉菌、宠物皮屑、蟑螂等）
    
    // 生活习惯相关
    let exerciseFrequencyPerWeek: Int   // 每周运动次数
    let exerciseDurationMinutes: Int    // 每次运动时间（分钟）
    let exerciseIntensity: String       // 强度：轻/中/重
    let swimming: Bool                  // 是否游泳
    
    let sleepHoursPerDay: Double         // 每日睡眠小时数
    let hasInsomnia: Bool                // 失眠
    let circadianRhythmDisorder: Bool   // 昼夜节律紊乱
    
    let smokingStatus: String            // 吸烟情况（主动/被动/无）
    let cleaningFrequency: String        // 清洁频率（每日/每周/每月）
    
    // 宠物饲养
    let hasCat: Bool
    let hasDog: Bool
    let hasBird: Bool
    let otherPets: String
    let petCount: Int                    // 宠物数量
    
    let smokerCohabitant: Bool           // 吸烟者同居情况
    
    // 烹饪燃料及设备
    let cookingFuelType: String          // 天然气/煤气/生物质燃料
    let airPurifierUsed: Bool            // 是否使用空气净化器
    let vacuumCleanerUsed: Bool          // 是否使用吸尘器
    
    let allergenAvoidanceEffectiveness: String  // 过敏原回避措施执行情况：优/良/差
}

struct UrbanRuralEnvironment {
    let patientId: Int32
    // 城市环境监测
    let cityPM25AnnualAverage: Double      // PM2.5年均浓度 (µg/m³)
    let cityPM25SeasonalVariation: String // PM2.5季节性变化描述
    let cityPollenMainTypes: String        // 主要花粉种类
    let cityPollenMonthlyDistribution: String // 月度分布
    let cityPollenPeakConcentration: Double    // 峰值浓度 (颗粒/司)
    let cityOtherPollutants: String        // 其他污染物（NO2、SO2、臭氧等）
    let cityMonitoringSiteType: String     // 监测点位置（交通区/工业区/居民区）
    
    // 农村环境监测
    let ruralPM25BurningPeriod: Double     // 秸秆焚烧期PM2.5浓度
    let ruralPM25AnnualAverage: Double     // PM2.5年均浓度
    let ruralCropPollenTypes: String       // 农作物相关花粉种类
    let biomassFuelIndoorPollution: Bool   // 生物质燃料使用导致室内污染（是/否）
    let drinkingWaterSource: String        // 饮用水源类型（自来水/纯净水/井水/其他）
}

struct FamilyHistory {
    let patientId: Int32
    
    // 一级亲属疾病（哮喘、湿疹、鼻炎、食物过敏）及关系（父、母、兄弟姐妹）
    let asthmaFirstDegree: Bool
    let eczemaFirstDegree: Bool
    let rhinitisFirstDegree: Bool
    let foodAllergyFirstDegree: Bool
    let relationFirstDegree: String // 例如："父母、哥哥、姐姐"
    
    // 二级亲属疾病及关系（祖父母、叔伯等）
    let asthmaSecondDegree: Bool
    let eczemaSecondDegree: Bool
    let rhinitisSecondDegree: Bool
    let foodAllergySecondDegree: Bool
    let relationSecondDegree: String // 例如："爷爷、奶奶、舅舅"
    
    // 家族环境居住相似性：共同暴露因素，如吸烟
    let sharedExposureSmoking: Bool
}

struct OtherConfoundingFactors {
    let patientId: Int32
    
    // 饮食习惯
    let dietHighProcessed: Bool     // 高加工食品
    let dietTraditional: Bool       // 传统饮食
    
    // 维生素D摄入
    let vitaminD_daily400u: Bool    // 每日400u
    let vitaminD_durationYears: Int // 口服周期（年）
    
    // Omega-3脂肪酸摄入量（单位：mg/天）
    let omega3_intakeMgPerDay: Int
    
    // 心理因素
    let stressLevel_PSS10: Int      // 长期压力水平（PSS-10分数）
    let anxietyDepression_PHQ9_GAD7: Int  // 焦虑或抑郁状态评分（PHQ-9/GAD-7）
    
    // 疫苗接种史
    let vaccine_planned: Bool       // 是否按计划接种
    
    // 抗生素使用频率（0=无，1=每月，2=每季度，3=每年）
    let antibiotic_useFrequency: Int
    
    // 早期生活暴露
    let breastfeeding: Bool         // 母乳喂养
    let breastfeedingMonths: Int    // 母乳喂养具体月数
    let delivery_natural: Bool      // 自然分娩
    let delivery_csection: Bool     // 剖宫产
    
    // 宠物接触年龄（0=无，1=婴儿期，2=幼儿期，3=学龄前，4=学龄期）
    let petExposureAge: Int
    
    // 农场环境暴露
    let farmExposure: Bool
    let farmExposureMonths: Int    // 具体月数
    
    // 疾病负担
    let allergyAbsenceDaysPerYear: Int // 因过敏导致的缺勤/缺课天数
}

struct StudyWorkEnvironment: Identifiable {
    let id = UUID()
    let patientId: Int32
    
    var location: String
    var ventilation: String
    var pm25AnnualAverage: Double
    var pollenPeakConcentration: Double
    var pollenTypes: String

    var formaldehydeLevel: Double
    var dustMiteExposure: Bool       
    var fabricFurnitureUse: Bool
}
