import Foundation

enum GameConfig {
    static let tickInterval: Double = 1.0 / 30.0
    static let baseOfflineCapHours: Double = 2.0
    static let offlineEfficiency: Double = 0.55
    static let tapCraftFraction: Double = 0.34
    static let boostChargePerCraft: Double = 0.012
    static let boostChargePerTap: Double = 0.006
    static let prestigeReputationFloor: Double = 2500

    static let workshops: [WorkshopDef] = [
        WorkshopDef(kind: .pottery, name: "Pottery Atelier", product: "Vases", symbol: "circle.hexagongrid.fill", accentHex: "C36A3E",
                    unlockCost: 0, baseUpgradeCost: 10, costGrowth: 1.14, craftTime: 2.5, baseOutput: 3, reputationPerCraft: 0.4, managerCost: 350, zone: .ceramicsCourt),
        WorkshopDef(kind: .painting, name: "Painter's Loft", product: "Canvases", symbol: "paintpalette.fill", accentHex: "C0556B",
                    unlockCost: 150, baseUpgradeCost: 90, costGrowth: 1.145, craftTime: 3.0, baseOutput: 14, reputationPerCraft: 0.7, managerCost: 2_000, zone: .artLane),
        WorkshopDef(kind: .furniture, name: "Furniture Workshop", product: "Chairs", symbol: "chair.lounge.fill", accentHex: "9A7B4F",
                    unlockCost: 1_400, baseUpgradeCost: 800, costGrowth: 1.15, craftTime: 3.5, baseOutput: 70, reputationPerCraft: 1.1, managerCost: 14_000, zone: .craftHall),
        WorkshopDef(kind: .glassblowing, name: "Glassblowing Studio", product: "Glassware", symbol: "flame.fill", accentHex: "4E9AA6",
                    unlockCost: 12_000, baseUpgradeCost: 6_500, costGrowth: 1.15, craftTime: 3.0, baseOutput: 320, reputationPerCraft: 1.6, managerCost: 110_000, zone: .ceramicsCourt),
        WorkshopDef(kind: .textiles, name: "Textile House", product: "Tapestries", symbol: "scissors", accentHex: "7C9A57",
                    unlockCost: 95_000, baseUpgradeCost: 52_000, costGrowth: 1.155, craftTime: 3.5, baseOutput: 1_400, reputationPerCraft: 2.3, managerCost: 850_000, zone: .craftHall),
        WorkshopDef(kind: .watchmaking, name: "Watchmaker's Bench", product: "Timepieces", symbol: "clock.fill", accentHex: "B08945",
                    unlockCost: 750_000, baseUpgradeCost: 410_000, costGrowth: 1.155, craftTime: 4.0, baseOutput: 6_200, reputationPerCraft: 3.2, managerCost: 6_500_000, zone: .fineAtelier),
        WorkshopDef(kind: .jewelry, name: "Jewelry Atelier", product: "Gems", symbol: "diamond.fill", accentHex: "8E6FB0",
                    unlockCost: 6_000_000, baseUpgradeCost: 3_200_000, costGrowth: 1.16, craftTime: 4.0, baseOutput: 27_000, reputationPerCraft: 4.4, managerCost: 52_000_000, zone: .fineAtelier),
        WorkshopDef(kind: .design, name: "Design Hub", product: "Concepts", symbol: "pencil.and.ruler.fill", accentHex: "3F7E8C",
                    unlockCost: 48_000_000, baseUpgradeCost: 26_000_000, costGrowth: 1.16, craftTime: 4.5, baseOutput: 120_000, reputationPerCraft: 6.0, managerCost: 420_000_000, zone: .artLane)
    ]

    static let zones: [ZoneDef] = [
        ZoneDef(kind: .ceramicsCourt, name: "Ceramics Court", subtitle: "Clay & glass in concert", symbol: "building.columns.fill", accentHex: "C36A3E",
                members: [.pottery, .glassblowing], requiredLevel: 10, productionMultiplier: 1.5, reputationMultiplier: 1.3, formCost: 500),
        ZoneDef(kind: .craftHall, name: "Craft Hall", subtitle: "Warm home making", symbol: "house.lodge.fill", accentHex: "9A7B4F",
                members: [.furniture, .textiles], requiredLevel: 10, productionMultiplier: 1.65, reputationMultiplier: 1.35, formCost: 4_000),
        ZoneDef(kind: .fineAtelier, name: "Fine Atelier", subtitle: "Precision & luxury", symbol: "sparkles", accentHex: "B08945",
                members: [.watchmaking, .jewelry], requiredLevel: 10, productionMultiplier: 1.8, reputationMultiplier: 1.4, formCost: 30_000),
        ZoneDef(kind: .artLane, name: "Art Lane", subtitle: "Vision made visible", symbol: "photo.artframe", accentHex: "C0556B",
                members: [.painting, .design], requiredLevel: 10, productionMultiplier: 2.0, reputationMultiplier: 1.5, formCost: 120_000),
        ZoneDef(kind: .grandQuarter, name: "Grand Quarter", subtitle: "A famous creative center", symbol: "crown.fill", accentHex: "B5852E",
                members: [], requiredLevel: 0, productionMultiplier: 2.0, reputationMultiplier: 1.8, formCost: 500_000)
    ]

    static let decorations: [DecorationDef] = [
        DecorationDef(kind: .lantern, name: "Paper Lantern", symbol: "lightbulb.fill", accentHex: "E0A65A", cost: 200, atmosphere: 0.5),
        DecorationDef(kind: .flowerBed, name: "Flower Bed", symbol: "leaf.fill", accentHex: "C66B83", cost: 600, atmosphere: 1.0),
        DecorationDef(kind: .bench, name: "Oak Bench", symbol: "chair.fill", accentHex: "9A7B4F", cost: 1_500, atmosphere: 1.8),
        DecorationDef(kind: .tree, name: "Quarter Tree", symbol: "tree.fill", accentHex: "6F934E", cost: 4_000, atmosphere: 3.5),
        DecorationDef(kind: .stringLights, name: "String Lights", symbol: "sparkles", accentHex: "E8C16A", cost: 12_000, atmosphere: 8),
        DecorationDef(kind: .mural, name: "Street Mural", symbol: "paintbrush.pointed.fill", accentHex: "C0556B", cost: 40_000, atmosphere: 22),
        DecorationDef(kind: .fountain, name: "Stone Fountain", symbol: "drop.fill", accentHex: "4E9AA6", cost: 150_000, atmosphere: 70),
        DecorationDef(kind: .statue, name: "Maker Statue", symbol: "figure.stand", accentHex: "9A8A6E", cost: 800_000, atmosphere: 300)
    ]

    static let streets: [StreetDef] = [
        StreetDef(index: 0, name: "Maker's Row", unlockCost: 0, decorationSlots: 6),
        StreetDef(index: 1, name: "Lantern Way", unlockCost: 25_000, decorationSlots: 8),
        StreetDef(index: 2, name: "Gallery Walk", unlockCost: 1_200_000, decorationSlots: 10),
        StreetDef(index: 3, name: "Grand Promenade", unlockCost: 90_000_000, decorationSlots: 12)
    ]

    static let quests: [QuestDef] = [
        QuestDef(id: "q1", title: "Open the Doors", detail: "Craft your first 5 goods.", symbol: "hand.tap.fill", metric: .goodsCrafted, target: 5, rewardCoins: 60, rewardReputation: 0, rewardBoost: nil),
        QuestDef(id: "q2", title: "A Steady Wheel", detail: "Upgrade workshops 3 times.", symbol: "arrow.up.circle.fill", metric: .workshopUpgrades, target: 3, rewardCoins: 140, rewardReputation: 0, rewardBoost: nil),
        QuestDef(id: "q3", title: "A Second Trade", detail: "Open a second workshop.", symbol: "plus.square.on.square", metric: .openWorkshopsNow, target: 2, rewardCoins: 320, rewardReputation: 20, rewardBoost: nil),
        QuestDef(id: "q4", title: "Word Spreads", detail: "Earn 60 reputation.", symbol: "star.fill", metric: .reputationEarned, target: 60, rewardCoins: 650, rewardReputation: 0, rewardBoost: nil),
        QuestDef(id: "q5", title: "A Helping Hand", detail: "Hire your first manager.", symbol: "person.fill.badge.plus", metric: .managersHired, target: 1, rewardCoins: 1_600, rewardReputation: 0, rewardBoost: .festivalDay),
        QuestDef(id: "q6", title: "Beautify the Block", detail: "Place 3 decorations.", symbol: "leaf.fill", metric: .decorationsPlaced, target: 3, rewardCoins: 2_800, rewardReputation: 40, rewardBoost: nil),
        QuestDef(id: "q7", title: "Form a Zone", detail: "Combine crafts into a cultural zone.", symbol: "building.columns.fill", metric: .zonesFormed, target: 1, rewardCoins: 9_000, rewardReputation: 0, rewardBoost: .goldenHour),
        QuestDef(id: "q8", title: "A Busy Quarter", detail: "Craft 250 goods.", symbol: "shippingbox.fill", metric: .goodsCrafted, target: 250, rewardCoins: 22_000, rewardReputation: 60, rewardBoost: nil),
        QuestDef(id: "q9", title: "Renowned Makers", detail: "Earn 1,200 reputation.", symbol: "star.circle.fill", metric: .reputationEarned, target: 1_200, rewardCoins: 60_000, rewardReputation: 0, rewardBoost: .inspirationSurge),
        QuestDef(id: "q10", title: "Grand Designs", detail: "Open 5 workshops.", symbol: "square.grid.3x3.fill", metric: .openWorkshopsNow, target: 5, rewardCoins: 180_000, rewardReputation: 120, rewardBoost: nil),
        QuestDef(id: "q11", title: "Master Makers", detail: "Reach 120 total workshop levels.", symbol: "chart.line.uptrend.xyaxis", metric: .totalWorkshopLevels, target: 120, rewardCoins: 700_000, rewardReputation: 0, rewardBoost: .festivalDay),
        QuestDef(id: "q12", title: "Cultural Center", detail: "Form 3 cultural zones.", symbol: "sparkles", metric: .zonesFormed, target: 3, rewardCoins: 3_000_000, rewardReputation: 400, rewardBoost: nil),
        QuestDef(id: "q13", title: "Reinvent the Quarter", detail: "Prestige for the first time.", symbol: "arrow.triangle.2.circlepath", metric: .prestiges, target: 1, rewardCoins: 0, rewardReputation: 80, rewardBoost: .goldenHour),
        QuestDef(id: "q14", title: "Living Legend", detail: "Craft 10,000 goods.", symbol: "flame.fill", metric: .goodsCrafted, target: 10_000, rewardCoins: 12_000_000, rewardReputation: 800, rewardBoost: nil),
        QuestDef(id: "q15", title: "The Whole Quarter", detail: "Form all four cultural zones.", symbol: "crown.fill", metric: .zonesFormed, target: 4, rewardCoins: 60_000_000, rewardReputation: 2_000, rewardBoost: .inspirationSurge)
    ]

    static let achievements: [AchievementDef] = [
        AchievementDef(id: "a1", title: "First Spin", detail: "Craft 1 good.", symbol: "hand.tap.fill", metric: .goodsCrafted, target: 1, rewardInspiration: 0),
        AchievementDef(id: "a2", title: "Hundred Hands", detail: "Craft 100 goods.", symbol: "shippingbox.fill", metric: .goodsCrafted, target: 100, rewardInspiration: 0),
        AchievementDef(id: "a3", title: "Workshop of Wonders", detail: "Craft 5,000 goods.", symbol: "sparkles", metric: .goodsCrafted, target: 5_000, rewardInspiration: 1),
        AchievementDef(id: "a4", title: "Tireless Maker", detail: "Craft 100,000 goods.", symbol: "flame.fill", metric: .goodsCrafted, target: 100_000, rewardInspiration: 3),
        AchievementDef(id: "a5", title: "Open for Business", detail: "Open 2 workshops.", symbol: "door.left.hand.open", metric: .openWorkshopsNow, target: 2, rewardInspiration: 0),
        AchievementDef(id: "a6", title: "Full House", detail: "Open all 8 workshops.", symbol: "square.grid.3x3.fill", metric: .openWorkshopsNow, target: 8, rewardInspiration: 2),
        AchievementDef(id: "a7", title: "Rising Star", detail: "Earn 500 reputation.", symbol: "star.fill", metric: .reputationEarned, target: 500, rewardInspiration: 0),
        AchievementDef(id: "a8", title: "Five Stars", detail: "Earn 50,000 reputation.", symbol: "star.circle.fill", metric: .reputationEarned, target: 50_000, rewardInspiration: 2),
        AchievementDef(id: "a9", title: "First Combine", detail: "Form 1 cultural zone.", symbol: "building.columns.fill", metric: .zonesFormed, target: 1, rewardInspiration: 1),
        AchievementDef(id: "a10", title: "Master Planner", detail: "Form all 5 zones.", symbol: "crown.fill", metric: .zonesFormed, target: 5, rewardInspiration: 4),
        AchievementDef(id: "a11", title: "Delegator", detail: "Hire 3 managers.", symbol: "person.3.fill", metric: .managersHired, target: 3, rewardInspiration: 1),
        AchievementDef(id: "a12", title: "Green Thumb", detail: "Place 10 decorations.", symbol: "leaf.fill", metric: .decorationsPlaced, target: 10, rewardInspiration: 1),
        AchievementDef(id: "a13", title: "Curator", detail: "Place 25 decorations.", symbol: "photo.artframe", metric: .decorationsPlaced, target: 25, rewardInspiration: 2),
        AchievementDef(id: "a14", title: "Crowd Pleaser", detail: "Welcome 1,000 visitors.", symbol: "figure.walk", metric: .visitorsWelcomed, target: 1_000, rewardInspiration: 1),
        AchievementDef(id: "a15", title: "Quarter Famous", detail: "Welcome 50,000 visitors.", symbol: "figure.2.and.child.holdinghands", metric: .visitorsWelcomed, target: 50_000, rewardInspiration: 3),
        AchievementDef(id: "a16", title: "Tap Master", detail: "Tap to craft 1,000 times.", symbol: "hand.point.up.left.fill", metric: .taps, target: 1_000, rewardInspiration: 1),
        AchievementDef(id: "a17", title: "Festive Spirit", detail: "Activate 10 boosts.", symbol: "party.popper.fill", metric: .boostsActivated, target: 10, rewardInspiration: 1),
        AchievementDef(id: "a18", title: "Reinventor", detail: "Reinvent the quarter once.", symbol: "arrow.triangle.2.circlepath", metric: .prestiges, target: 1, rewardInspiration: 0),
        AchievementDef(id: "a19", title: "Reborn Thrice", detail: "Reinvent 3 times.", symbol: "arrow.triangle.2.circlepath.circle.fill", metric: .prestiges, target: 3, rewardInspiration: 3),
        AchievementDef(id: "a20", title: "Deep Pockets", detail: "Hold 1,000,000 coins at once.", symbol: "circle.fill", metric: .coinsBalance, target: 1_000_000, rewardInspiration: 1),
        AchievementDef(id: "a21", title: "Grand Levels", detail: "Reach 300 total workshop levels.", symbol: "chart.line.uptrend.xyaxis", metric: .totalWorkshopLevels, target: 300, rewardInspiration: 3),
        AchievementDef(id: "a22", title: "Devoted Maker", detail: "Play for 1 hour.", symbol: "clock.fill", metric: .secondsPlayed, target: 3_600, rewardInspiration: 1)
    ]

    static let prestigeUpgrades: [PrestigeUpgradeDef] = [
        PrestigeUpgradeDef(kind: .mastersTouch, name: "Master's Touch", detail: "+25% production per level.", symbol: "hand.raised.fill", baseCost: 1, costGrowth: 2.2, effectPerLevel: 0.25, maxLevel: 50),
        PrestigeUpgradeDef(kind: .renownedQuarter, name: "Renowned Quarter", detail: "+20% reputation gain per level.", symbol: "star.fill", baseCost: 1, costGrowth: 2.0, effectPerLevel: 0.20, maxLevel: 50),
        PrestigeUpgradeDef(kind: .patronNetwork, name: "Patron Network", detail: "+1h offline cap per level.", symbol: "clock.badge.checkmark.fill", baseCost: 2, costGrowth: 2.5, effectPerLevel: 1.0, maxLevel: 22),
        PrestigeUpgradeDef(kind: .swiftHands, name: "Swift Hands", detail: "+8% craft speed per level.", symbol: "bolt.fill", baseCost: 2, costGrowth: 2.4, effectPerLevel: 0.08, maxLevel: 25),
        PrestigeUpgradeDef(kind: .welcomingLanterns, name: "Welcoming Lanterns", detail: "+30% visitor income per level.", symbol: "lightbulb.fill", baseCost: 1, costGrowth: 2.1, effectPerLevel: 0.30, maxLevel: 40)
    ]

    static let masterpieces: [MasterpieceDef] = [
        MasterpieceDef(id: "m1", name: "The Moonlit Vase", workshop: .pottery, requiredLevel: 20, symbol: "circle.hexagongrid.fill", flavor: "A glaze that catches the evening light."),
        MasterpieceDef(id: "m2", name: "Quarter at Dusk", workshop: .painting, requiredLevel: 20, symbol: "paintpalette.fill", flavor: "The whole district in golden hour."),
        MasterpieceDef(id: "m3", name: "The Reading Chair", workshop: .furniture, requiredLevel: 20, symbol: "chair.lounge.fill", flavor: "Oak worn smooth by a thousand stories."),
        MasterpieceDef(id: "m4", name: "Ribbon of Glass", workshop: .glassblowing, requiredLevel: 20, symbol: "flame.fill", flavor: "Frozen mid-pour, impossibly thin."),
        MasterpieceDef(id: "m5", name: "The Wandering Tapestry", workshop: .textiles, requiredLevel: 20, symbol: "scissors", flavor: "Every traveller who ever passed through."),
        MasterpieceDef(id: "m6", name: "The Patient Clock", workshop: .watchmaking, requiredLevel: 20, symbol: "clock.fill", flavor: "Two hundred gears, one heartbeat."),
        MasterpieceDef(id: "m7", name: "The Dawn Brooch", workshop: .jewelry, requiredLevel: 20, symbol: "diamond.fill", flavor: "A single gem the colour of sunrise."),
        MasterpieceDef(id: "m8", name: "Blueprint of Tomorrow", workshop: .design, requiredLevel: 20, symbol: "pencil.and.ruler.fill", flavor: "The quarter as it will one day be.")
    ]

    static let boosts: [BoostDef] = [
        BoostDef(kind: .festivalDay, name: "Festival Day", detail: "x2 production", symbol: "party.popper.fill", duration: 60, productionMultiplier: 2, reputationMultiplier: 1),
        BoostDef(kind: .goldenHour, name: "Golden Hour", detail: "x3 production", symbol: "sun.haze.fill", duration: 45, productionMultiplier: 3, reputationMultiplier: 1),
        BoostDef(kind: .inspirationSurge, name: "Inspiration Surge", detail: "x3 reputation", symbol: "sparkles", duration: 45, productionMultiplier: 1, reputationMultiplier: 3)
    ]

    static func workshop(_ kind: WorkshopKind) -> WorkshopDef { workshops.first { $0.kind == kind }! }
    static func zone(_ kind: ZoneKind) -> ZoneDef { zones.first { $0.kind == kind }! }
    static func decoration(_ kind: DecorationKind) -> DecorationDef { decorations.first { $0.kind == kind }! }
    static func boost(_ kind: BoostKind) -> BoostDef { boosts.first { $0.kind == kind }! }
    static func prestige(_ kind: PrestigeUpgradeKind) -> PrestigeUpgradeDef { prestigeUpgrades.first { $0.kind == kind }! }
    static func quest(_ id: String) -> QuestDef? { quests.first { $0.id == id } }
}
