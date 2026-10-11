import SwiftUI

struct FemaleScores: View {

    // MARK: - Environment
    @EnvironmentObject var history: FitnessHistory
    @EnvironmentObject var reviewPrompter: ReviewPrompter

    // MARK: - Save / Share state
    @State private var justSaved       = false
    @State private var shareableImage: ShareableImage?

    // MARK: - State
    @AppStorage("f_pullUps")   private var pullUpsCount:       Double = 0
    @AppStorage("f_jump")      private var jumpDistanceInches: Double = 60
    @AppStorage("f_sitUps")    private var sitUpsCount:        Double = 0
    @AppStorage("f_pushUps")   private var pushUpsCount:       Double = 0
    @AppStorage("f_runIdx")    private var runTimeIndex:       Int    = 0
    @AppStorage("f_aftSecs")   private var aftTimeInSeconds:   Int    = 967

    // MARK: - Score Tables (static so they're built once, not on every redraw)
    static let pullUpScores: [Int] = [0, 25, 37, 50, 57, 67, 78, 89, 100]

    static let jumpScores: [Int: Int] = [
        60: 0, 61: 1, 62: 4, 63: 6, 64: 9, 65: 12, 66: 15, 67: 18, 68: 22, 69: 25,
        70: 29, 71: 33, 72: 37, 73: 41, 74: 45, 75: 50, 76: 53, 77: 58, 78: 62, 79: 67,
        80: 71, 81: 76, 82: 80, 83: 85, 84: 90, 85: 95, 86: 100
    ]

    static let sitUpScores: [Int: Int] = [
        0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0, 13: 0, 14: 0, 15: 0, 16: 0,
        17: 0, 18: 0, 19: 0, 20: 0, 21: 0, 22: 0, 23: 0, 24: 0, 25: 0, 26: 0, 27: 0, 28: 0, 29: 0, 30: 0, 31: 0, 32: 0,
        33: 0, 34: 0, 35: 0, 36: 0, 37: 0, 38: 0, 39: 0, 40: 0, 41: 0, 42: 0, 43: 1, 44: 2, 45: 4, 46: 5, 47: 7, 48: 8,
        49: 10, 50: 11, 51: 13, 52: 15, 53: 16, 54: 18, 55: 20, 56: 22, 57: 23, 58: 25, 59: 27, 60: 29, 61: 31, 62: 33,
        63: 34, 64: 36, 65: 38, 66: 40, 67: 42, 68: 44, 69: 46, 70: 48, 71: 50, 72: 52, 73: 54, 74: 56, 75: 58, 76: 60,
        77: 62, 78: 64, 79: 66, 80: 68, 81: 70, 82: 72, 83: 74, 84: 77, 85: 79, 86: 81, 87: 83, 88: 85, 89: 87, 90: 89,
        91: 91, 92: 94, 93: 96, 94: 98, 95: 100
    ]

    static let pushUpScores: [Int: Int] = [
        0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 1, 6: 2, 7: 4, 8: 6, 9: 7,
        10: 9, 11: 11, 12: 13, 13: 15, 14: 17, 15: 19, 16: 21, 17: 23, 18: 25, 19: 27,
        20: 30, 21: 32, 22: 34, 23: 37, 24: 39, 25: 41, 26: 44, 27: 46, 28: 48, 29: 50,
        30: 53, 31: 56, 32: 58, 33: 61, 34: 63, 35: 66, 36: 68, 37: 71, 38: 73, 39: 76,
        40: 79, 41: 81, 42: 84, 43: 86, 44: 89, 45: 92, 46: 95, 47: 97, 48: 100
    ]

    static let runTimesInSeconds: [Int] = Array(stride(from: 154, through: 113, by: -1))
    static let runScores: [Int: Int] = [
        154: 0, 153: 2, 152: 4, 151: 7, 150: 9, 149: 11, 148: 13, 147: 16, 146: 18, 145: 20,
        144: 22, 143: 25, 142: 27, 141: 29, 140: 31, 139: 34, 138: 36, 137: 38, 136: 41, 135: 43,
        134: 45, 133: 48, 132: 50, 131: 52, 130: 55, 129: 57, 128: 60, 127: 62, 126: 64, 125: 67,
        124: 69, 123: 72, 122: 74, 121: 77, 120: 80, 119: 82, 118: 85, 117: 88, 116: 90, 115: 93,
        114: 96, 113: 100
    ]

    static let maxAftTimeInSeconds = 967   // 16:07
    static let minAftTimeInSeconds = 535   // 8:55

    static let aftTimesToScores: [Int: Int] = [
        535: 500, 536: 499, 537: 498, 538: 498, 539: 497, 540: 497, 541: 496, 542: 496, 543: 495, 544: 495,
        545: 494, 546: 494, 547: 493, 548: 493, 549: 492, 550: 492, 551: 491, 552: 491, 553: 490, 554: 490,
        555: 489, 556: 489, 557: 488, 558: 488, 559: 487, 560: 487, 561: 486, 562: 486, 563: 485, 564: 485,
        565: 484, 566: 484, 567: 483, 568: 483, 569: 482, 570: 482, 571: 481, 572: 480, 573: 479, 574: 479,
        575: 478, 576: 478, 577: 477, 578: 476, 579: 475, 580: 474, 581: 473, 582: 472, 583: 471, 584: 470,
        585: 469, 586: 468, 587: 467, 588: 467, 589: 466, 590: 466, 591: 465, 592: 464, 593: 463, 594: 462,
        595: 462, 596: 461, 597: 461, 598: 460, 599: 459, 600: 458, 601: 458, 602: 457, 603: 457, 604: 456,
        605: 456, 606: 455, 607: 455, 608: 454, 609: 454, 610: 453, 611: 453, 612: 452, 613: 452, 614: 451,
        615: 451, 616: 450, 617: 450, 618: 449, 619: 449, 620: 447, 621: 447, 622: 445, 623: 443, 624: 441,
        625: 439, 626: 437, 627: 425, 628: 425, 629: 424, 630: 424, 631: 422, 632: 422, 633: 420, 634: 420,
        635: 418, 636: 418, 637: 416, 638: 416, 639: 414, 640: 414, 641: 412, 642: 412, 643: 410, 644: 410,
        645: 408, 646: 408, 647: 406, 648: 406, 649: 404, 650: 404, 651: 402, 652: 402, 653: 400, 654: 399,
        655: 399, 656: 397, 657: 397, 658: 395, 659: 395, 660: 393, 661: 393, 662: 391, 663: 391, 664: 391,
        665: 391, 666: 389, 667: 389, 668: 389, 669: 387, 670: 387, 671: 387, 672: 387, 673: 385, 674: 385,
        675: 383, 676: 385, 677: 381, 678: 381, 679: 379, 680: 379, 681: 377, 682: 377, 683: 375, 684: 375,
        685: 373, 686: 373, 687: 371, 688: 371, 689: 370, 690: 370, 691: 369, 692: 369, 693: 367, 694: 363,
        695: 363, 696: 361, 697: 361, 698: 359, 699: 357, 700: 355, 701: 355, 702: 353, 703: 353, 704: 351,
        705: 349, 706: 347, 707: 345, 708: 345, 709: 343, 710: 343, 711: 341, 712: 339, 713: 337, 714: 335,
        715: 333, 716: 333, 717: 331, 718: 331, 719: 330, 720: 330, 721: 330, 722: 327, 723: 327, 724: 327,
        725: 325, 726: 325, 727: 325, 728: 323, 729: 323, 730: 323, 731: 321, 732: 321, 733: 319, 734: 319,
        735: 317, 736: 317, 737: 315, 738: 315, 739: 313, 740: 313, 741: 311, 742: 311, 743: 311, 744: 309,
        745: 309, 746: 307, 747: 307, 748: 305, 749: 305, 750: 303, 751: 303, 752: 301, 753: 301, 754: 299,
        755: 299, 756: 297, 757: 297, 758: 295, 759: 295, 760: 293, 761: 293, 762: 291, 763: 291, 764: 291,
        765: 290, 766: 290, 767: 290, 768: 290, 769: 290, 770: 290, 771: 290, 772: 285, 773: 285, 774: 285,
        775: 285, 776: 285, 777: 285, 778: 285, 779: 285, 780: 280, 781: 280, 782: 280, 783: 280, 784: 280,
        785: 280, 786: 280, 787: 275, 788: 275, 789: 275, 790: 275, 791: 270, 792: 270, 793: 270, 794: 270,
        795: 270, 796: 265, 797: 265, 798: 265, 799: 265, 800: 265, 801: 260, 802: 260, 803: 260, 804: 255,
        805: 255, 806: 255, 807: 255, 808: 250, 809: 250, 810: 250, 811: 250, 812: 249, 813: 249, 814: 249,
        815: 249, 816: 244, 817: 244, 818: 244, 819: 244, 820: 239, 821: 239, 822: 239, 823: 239, 824: 234,
        825: 234, 826: 234, 827: 234, 828: 229, 829: 229, 830: 229, 831: 229, 832: 226, 833: 226, 834: 226,
        835: 225, 836: 225, 837: 225, 838: 225, 839: 220, 840: 220, 841: 220, 842: 215, 843: 215, 844: 215,
        845: 215, 846: 210, 847: 210, 848: 210, 849: 210, 850: 205, 851: 205, 852: 205, 853: 205, 854: 200,
        855: 200, 856: 200, 857: 200, 858: 190, 859: 150, 860: 150, 861: 150, 862: 150, 863: 150, 864: 150,
        865: 150, 866: 150, 867: 150, 868: 150, 869: 150, 870: 150, 871: 150, 872: 150, 873: 150, 874: 150,
        875: 150, 876: 150, 877: 150, 878: 150, 879: 150, 880: 150, 881: 150, 882: 150, 883: 150, 884: 150,
        885: 150, 886: 100, 887: 100, 888: 100, 889: 100, 890: 100, 891: 100, 892: 100, 893: 100, 894: 100,
        895: 100, 896: 100, 897: 100, 898: 100, 899: 100, 900: 100, 901: 100, 902: 100, 903: 100, 904: 100,
        905: 100, 906: 100, 907: 100, 908: 100, 909: 100, 910: 100, 911: 100, 912: 100, 913: 100, 914: 100,
        915: 100, 916: 100, 917: 100, 918: 100, 919: 100, 920: 100, 921: 100, 922: 100, 923: 100, 924: 100,
        925: 100, 926: 100, 927: 100, 928: 100, 929: 100, 930: 100, 931: 50,  932: 50,  933: 50,  934: 50,
        935: 50,  936: 50,  937: 50,  938: 50,  939: 50,  940: 50,  941: 50,  942: 50,  943: 50,  944: 50,
        945: 50,  946: 50,  947: 50,  948: 50,  949: 50,  950: 50,  951: 50,  952: 50,  953: 50,  954: 50,
        955: 50,  956: 50,  957: 50,  958: 50,  959: 50,  960: 50,  961: 50,  962: 50,  963: 50,  964: 50,
        965: 50,  966: 50,  967: 0
    ]

    // MARK: - Computed Scores
    var aftScore: Int { Self.aftTimesToScores[aftTimeInSeconds] ?? 0 }

    var pullUpScore: Int { Self.pullUpScores[min(Int(pullUpsCount), Self.pullUpScores.count - 1)] }
    var jumpScore:   Int { Self.jumpScores[Int(jumpDistanceInches), default: 0] }
    var sitUpScore:  Int { Self.sitUpScores[Int(sitUpsCount), default: 0] }
    var pushUpScore: Int { Self.pushUpScores[Int(pushUpsCount), default: 0] }
    var runScore:    Int {
        let idx = min(max(runTimeIndex, 0), Self.runTimesInSeconds.count - 1)
        return Self.runScores[Self.runTimesInSeconds[idx], default: 0]
    }
    var totalPFTScore: Int { pullUpScore + jumpScore + sitUpScore + pushUpScore + runScore }

    // Formatted display values
    private var aftTimeString: String {
        "\(aftTimeInSeconds / 60):\(String(format: "%02d", aftTimeInSeconds % 60))"
    }
    private var runTimeString: String {
        let s = Self.runTimesInSeconds[min(max(runTimeIndex, 0), Self.runTimesInSeconds.count - 1)]
        return "\(s / 60):\(String(format: "%02d", s % 60))"
    }
    private var jumpString: String {
        "\(Int(jumpDistanceInches) / 12)'\(String(format: "%02d", Int(jumpDistanceInches) % 12))\""
    }

    // Accent color for female view (uses gold to differentiate slightly)
    private let accentColor = Color.usafaNavyAdaptive

    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // ── Score Summary Rings ─────────────────────────────
                scoreRingsSection
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                // ── Save / Share Actions ────────────────────────────
                actionButtons
                    .padding(.horizontal, 16)

                // ── AFT Section ─────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Aerobic Fitness Test", icon: "figure.run")
                    aftCard
                }
                .padding(.horizontal, 16)

                // ── PFT Section ─────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Physical Fitness Test", icon: "figure.strengthtraining.traditional")
                    pullUpsCard
                    jumpCard
                    sitUpsCard
                    pushUpsCard
                    runCard
                }
                .padding(.horizontal, 16)

                Spacer().frame(height: 40)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .sheet(item: $shareableImage, onDismiss: { reviewPrompter.recordSignificantAction() }) { wrapper in
            ShareSheet(activityItem: ShareActivityItem(image: wrapper.image, gender: wrapper.gender))
        }
    }

    // MARK: - Action Buttons (Save + Share)
    private var actionButtons: some View {
        HStack(spacing: 10) {
            // Save Session
            Button {
                let session = FitnessSession(
                    gender: "Female",
                    aftScore: aftScore,
                    pullUpScore: pullUpScore,
                    jumpScore: jumpScore,
                    sitUpScore: sitUpScore,
                    pushUpScore: pushUpScore,
                    runScore: runScore
                )
                history.add(session)
                reviewPrompter.recordSignificantAction()
                withAnimation(.spring(response: 0.3)) { justSaved = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation { justSaved = false }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: justSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                        .font(.system(size: 13, weight: .semibold))
                    Text(justSaved ? "Saved!" : "Save Session")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundColor(justSaved ? Color(red: 0.13, green: 0.80, blue: 0.43) : .white)
                .background(justSaved ? Color(red: 0.13, green: 0.80, blue: 0.43).opacity(0.15) : Color.usafaNavyAdaptive)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(justSaved ? Color(red: 0.13, green: 0.80, blue: 0.43) : Color.clear, lineWidth: 1)
                )
            }

            // Share
            Button {
                if let img = renderShareCard(
                    gender: "Female",
                    aftScore: aftScore,
                    pullUpScore: pullUpScore,
                    jumpScore: jumpScore,
                    sitUpScore: sitUpScore,
                    pushUpScore: pushUpScore,
                    runScore: runScore
                ) {
                    shareableImage = ShareableImage(image: img, gender: "Female")
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Share")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundColor(Color.usafaNavyAdaptive)
                .background(Color.usafaNavyAdaptive.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    // MARK: - Score Rings
    private var scoreRingsSection: some View {
        HStack(spacing: 16) {
            let aftInfo = gradeInfo(for: aftScore)
            ScoreRingView(
                score: aftScore, maxScore: 500,
                label: "AFT",
                grade: aftInfo.grade,
                pointScale: aftInfo.pointScale
            )
            .frame(height: 170)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)

            let pftInfo = gradeInfo(for: totalPFTScore)
            ScoreRingView(
                score: totalPFTScore, maxScore: 500,
                label: "PFT",
                grade: pftInfo.grade,
                pointScale: pftInfo.pointScale
            )
            .frame(height: 170)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
    }

    // MARK: - AFT Card
    private var aftCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("1.5 Mile Run")
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .tracking(0.8)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                    Text(aftTimeString)
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(accentColor)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: aftTimeInSeconds)
                }
                Spacer()
                PointsBadge(points: aftScore, maxPoints: 500)
            }

            MiniProgressBar(points: aftScore, maxPoints: 500)

            Slider(
                value: Binding(
                    get: { Double(Self.maxAftTimeInSeconds - aftTimeInSeconds) },
                    set: { aftTimeInSeconds = Self.maxAftTimeInSeconds - Int($0) }
                ),
                in: 0...Double(Self.maxAftTimeInSeconds - Self.minAftTimeInSeconds)
            )
            .tint(accentColor)

            HStack {
                Text("Best: 8:55")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                let info = gradeInfo(for: aftScore)
                GradeBadge(grade: info.grade, pointScale: info.pointScale)
                Spacer()
                Text("Min: 16:07")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .cardStyle()
    }

    // MARK: - PFT Cards
    private var pullUpsCard: some View {
        exerciseCard(title: "Pull-Ups", value: "\(Int(pullUpsCount)) reps",
                     points: pullUpScore, maxPoints: 100) {
            Slider(value: $pullUpsCount, in: 0...Double(Self.pullUpScores.count - 1), step: 1)
                .tint(accentColor)
        }
    }

    private var jumpCard: some View {
        exerciseCard(title: "Standing Broad Jump", value: jumpString,
                     points: jumpScore, maxPoints: 100) {
            Slider(value: $jumpDistanceInches, in: 60...86, step: 1)
                .tint(accentColor)
        }
    }

    private var sitUpsCard: some View {
        exerciseCard(title: "Sit-Ups", value: "\(Int(sitUpsCount)) reps",
                     points: sitUpScore, maxPoints: 100) {
            Slider(value: $sitUpsCount, in: 0...95, step: 1)
                .tint(accentColor)
        }
    }

    private var pushUpsCard: some View {
        exerciseCard(title: "Push-Ups", value: "\(Int(pushUpsCount)) reps",
                     points: pushUpScore, maxPoints: 100) {
            Slider(value: $pushUpsCount, in: 0...48, step: 1)
                .tint(accentColor)
        }
    }

    private var runCard: some View {
        exerciseCard(title: "600m Run", value: runTimeString,
                     points: runScore, maxPoints: 100) {
            Slider(
                value: Binding(
                    get: { Double(runTimeIndex) },
                    set: { runTimeIndex = min(max(Int($0), 0), Self.runTimesInSeconds.count - 1) }
                ),
                in: 0...Double(Self.runTimesInSeconds.count - 1)
            )
            .tint(accentColor)
        }
    }

    // MARK: - Reusable Exercise Card (no icons)
    @ViewBuilder
    private func exerciseCard<S: View>(
        title: String,
        value: String,
        points: Int,
        maxPoints: Int,
        @ViewBuilder slider: () -> S
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .tracking(0.8)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(accentColor)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.25), value: value)
                }
                Spacer()
                PointsBadge(points: points, maxPoints: maxPoints)
            }

            MiniProgressBar(points: points, maxPoints: maxPoints)
            slider()
        }
        .cardStyle()
    }
}

// MARK: - Preview
#Preview {
    FemaleScores()
        .environmentObject(FitnessHistory())
        .environmentObject(ReviewPrompter())
        .environmentObject(FitnessHistory())
}

#Preview("Dark") {
    FemaleScores()
        .environmentObject(FitnessHistory())
        .environmentObject(ReviewPrompter())
        .environmentObject(FitnessHistory())
        .preferredColorScheme(.dark)
}
