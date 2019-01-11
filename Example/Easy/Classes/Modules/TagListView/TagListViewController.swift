//
//  TagListViewController.swift
//  Easy
//
//  Created by OctMon on 2018/11/29.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

private let spacing: CGFloat = 5

class TagListViewController: easy.ViewController, easy.TableListProtocol {
    
    typealias EasyTableListViewAssociatedType = easy.TableListView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        request()
    }
    
    override func configure() {
        super.configure()
        
        addTableListView(in: view, style: .grouped).addRefresh(isAddHeader: true, isAddFooter: false) { [weak self] in
            self?.request()
        }
        tableView.estimatedRowHeight = 44
        tableListView.register(String.self, cellClass:UITableViewCell.self, configureCell: { (listView, cell, indexPath, any) in
            cell.textLabel?.text = any
            cell.textLabel?.numberOfLines = 0
        }) { (_, _, any) in
            let tags = any.components("、")
            let tagListView = easy.TagListView().then {
                $0.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
                $0.minimumInteritemSpacing = spacing
                $0.minimumLineSpacing = spacing
                $0.textColor = .random
                $0.borderColor = $0.textColor
                $0.borderWidth = CGFloat.random(in: 1..<3)
                $0.font = UIFont.systemFont(ofSize: CGFloat.random(in: 18..<36))
                $0.setCornerRadius(5)
            }
            tagListView.setTags(tags, maxConstrainedHeight: .screenWidth, tap: { (offset) in
                log.debug(tags[offset])
            })
            easy.PopupView(tagListView, transition: .fade).showWithCenter()
            tagListView.snp.makeConstraints({ (make) in
                make.width.equalToSuperview().offset(-30)
                make.center.equalToSuperview()
            })
        }
    }
    
    override func request() {
        super.request()
        
        tableList = [
            [
                "瞥、瞅、望、瞄、瞪、盯、观察、凝视、注视、看望、探望、瞻仰、扫视、环视、仰望、俯视、鸟瞰、俯瞰、远望、眺望、了望",
                "讲、讨论、议论、谈论、交流、交谈",
                "嚷、吼、嚎、啼、鸣、嘶、嘶叫、嚎叫、叫嚷",
                "首、元、甲、子、首先、冠军、魁首、首屈一指、名列前茅",
                ],
            [
                "吱呀、喀嚓、扑哧、哗啦、沙沙、咕咚、叮当、咕噜、嗖嗖、唧唧喳喳、叽叽喳喳、轰轰隆隆、叮叮当当、叮叮咚咚、哗哗啦啦",
                "鸟语花香、春暖花开、阳春三月、万物复苏、春风轻拂、春光明媚",
                "烈日当空、暑气逼人、大汗淋漓、挥汗如雨、乌云翻滚、热不可耐",
                "秋高气爽、五谷丰登、百花凋谢、天高云淡、落叶沙沙、中秋月圆",
                "三九严寒、天寒地冻、雪花飞舞、寒冬腊月、千里冰封、滴水成冰",
                ],
            [
                "头重脚轻、指手画脚、愁眉苦脸、心明眼亮、目瞪口呆、张口结舌 交头接耳、面黄肌瘦、眼明手快、眼高手低、昂首挺胸、心灵手巧 摩拳擦掌、摩肩接踵",
                "鼠目寸光、胆小如鼠、投鼠忌器、兔死狐悲、杯弓蛇影、管中窥豹 与虎谋皮、雄狮猛虎、龙争虎斗、虎背熊腰、谈虎色变、狐假虎威、 叶公好龙、望子成龙、望女成凤、鱼龙混杂、鱼目混珠、声名狼籍、 惊弓之鸟、鸟语花香、莺歌燕舞、鸦雀无声、门可罗雀、爱屋及乌、画蛇添足、一箭双雕、狗急跳墙、狗尾续貂、螳臂当车、打草惊蛇 顺手牵羊、亡羊补牢、马不停蹄、马到成功、龙马精神、马失前蹄、指鹿为马、蛛丝马迹、一马当先、闻鸡起舞、雄鸡报晓、鹤立鸡群 杀鸡取卵、鸡犬不宁、鸡飞蛋打、鸡毛蒜皮、杀鸡儆猴、小试牛刀、九牛一毛、牛头马面、牛鬼蛇神、牛马不如、牛角挂书、对牛弹琴 牛毛细雨、如牛负重、风马牛不相及、初生牛犊不怕虎、九牛二虎之力",
                "鹅黄、乳白、湖蓝、枣红、雪白、火红、梨黄、孔雀蓝、柠檬黄、象牙白、苹果绿、金灿灿、黄澄澄、绿莹莹、红彤彤、红艳艳、红通通、白茫茫、黑乎乎、黑压压、桃红柳绿、万紫千红、青红皂白、黑白分明、绿意盎然、绿树成阴、素车白马、万古长青、漆黑一团、灯红酒绿、面红耳赤、青山绿水、白纸黑字、青黄不接",
                ],
            [
                "一诺千金、一鸣惊人、一马当先、一触即发、一气呵成、一丝不苟、一言九鼎、一日三秋、一落千丈、一字千金、一本万利、一手遮天、一文不值、一贫如洗、一身是胆、一毛不拔、二三其德、两面三刀、两肋插刀、两败俱伤、两情相悦、两袖清风、两全其美、三生有幸、三思而行、三令五申、三头六臂、三更半夜、三顾茅庐、四面楚歌、四面八方、四海为家、四通八达、四平八稳、四分五裂、五大三粗、五光十色、五花八门、五体投地、五谷丰登、五彩缤纷、五湖四海、六神无主、六根清净、六道轮回、六亲不认、七零八落、七嘴八舌、七高八低、七窍生烟、七上八下、七折八扣、七拼八凑、八面玲珑、八面威风、八仙过海 各显神通、九霄云外、九牛一毛、九死一生、九鼎一丝、九牛二虎之力、十指连心、十面埋伏、十字街头、十全十美、十年寒窗、十万火急、十拿九稳、百年大计、百花齐放、百思不解、百家争鸣、百感交集、百读不厌、百川归海、千方百计、千军万马、千言万语、千辛万苦、千秋万代、千真万确、千里鹅毛、万无一失、万众一心、万事大吉、万人空巷、万家灯火、万象更新、万人瞩目",
                ]
        ]
        
        tableView.mj_header.endRefreshing()
        tableView.reloadData()
    }
    
}
