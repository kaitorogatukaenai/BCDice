#--*-coding:utf-8-*--

class Cthulhuyaziumavr < DiceBot
  

  #def prefixs
      setPrefixes(['RES?.*', 'CBR?\(\d+,\d+\)', 'ISAN', 'TSAN', 'DSAN'])
  #end
  def gameName
    'クトゥルフ:やじうまさんVr'
  end
  
  def gameType
    "Cthulhuyaziumavr"
  end
  def getHelpMessage
    info = <<INFO_MESSAGE_TEXT
ハウスルールにより、96~100は必ずファンブルが出るよう設定されています。
・1D100の目標値判定で、クリティカル(決定的成功)／スペシャル／ファンブル(致命的失敗)の自動判定。
　例）1D100<=50
　　　Cthulhuyaziuma : (1D100<=50) → 96 → 致命的失敗

・抵抗ロール　(RES(x-n))
　RES(自分の能力値-相手の能力値)で記述します。
　抵抗ロールに変換して成功したかどうかを表示します。
　例）RES(12-10)
　　　Cthulhuyaziuma : (1d100<=60) → 35 → 成功

・組み合わせ判定　(CBR(x,y))
　目標値 x と y で％ロールを行い、成功したかどうかを表示します。
　例）CBR(50,20)
　　　Cthulhuyaziuma : (1d100<=70,20) → 22[成功,失敗] → 失敗
　　　TSANは一時狂気表となり
　　　ISANは不定狂気表となり
　　　DSANはドリームランド内での狂気表となる
INFO_MESSAGE_TEXT
  end
  
  def rollDiceCommand(command)
    # CoC抵抗表コマンド
    case command
    when /RES/i
      return getRegistResult(command)
    when /CBR/i
      return getCombineRoll(command)
    when /TSAN/
      return getTsanCheck(command)
    when /ISAN/i
      return getIsanCheck(command)
    when /DSAN/i
      return getDreamCheck(command)
    end
    
    return nil
  end
  
  
  def check_1D100(total_n, dice_n, signOfInequality, diff, dice_cnt, dice_max, n1, n_max)    # ゲーム別成功度判定(1d100)
    return '' unless(signOfInequality == "<=")
    
    return ' ＞ ' + getCheckResultText(total_n, diff)
  end
  
  def getCheckResultText(total_n, diff)
    if((total_n <= diff) and (total_n < 96))
      
      if(total_n <= 5)
        #if(total_n <= (diff / 5))
          #return "決定的成功/スペシャル";
        #end
        return "決定的成功";
      end
      
      if(total_n <= (diff / 5))
        return "スペシャル";
      end
      
      return "成功";
    end
    
    if(total_n >= 96) #and (diff < 100))
      return "致命的失敗";
    end
    
    return "失敗";
  end
  
  
  def getRegistResult(command)
    output = "1";
    
    return output unless(/RES?([-\d]+)/i =~ command)
    
    value = $1.to_i
    target =  value * 5 + 50;
    
    if(target < 5)    # 自動失敗
      return "(1d100<=#{target}) ＞ 自動失敗";
    end
    
    if(target > 95)  # 自動成功
      return "(1d100<=#{target}) ＞ 自動成功";
    end
    
    # 通常判定
#    total_n, dice_dmy = roll(1, 100);
    total_n, = roll(1, 100)
    result =  getCheckResultText(total_n, target)
   # if(total_n <= target)
    #  return "(1d100<=#{target}) ＞ #{total_n} ＞ 成功";
    #end
    
    #return "(1d100<=#{target}) ＞ #{total_n} ＞ 失敗";
    return "(1d100<=#{target}) ＞ #{total_n} ＞ #{result}"
  end
  
  
  def getCombineRoll(command)
    output = "1";
    
    return output unless(/CBR?\((\d+),(\d+)\)/i =~ command)
    
    diff_1 = $1.to_i
    diff_2 = $2.to_i
    
    total, = roll(1, 100)
    
    result_1 = getCheckResultText(total, diff_1)
    result_2 = getCheckResultText(total, diff_2)
    
    ranks = ["決定的成功/スペシャル", "決定的成功", "スペシャル", "成功", "失敗", "致命的失敗"]
    rankIndex_1 = ranks.index(result_1)
    rankIndex_2 = ranks.index(result_2)
       successList = ["決定的成功/スペシャル", "決定的成功", "スペシャル", "成功"]
    failList = ["失敗", "致命的失敗"]

    succesCount = 0
    succesCount += 1 if successList.include?( result_1 )
    succesCount += 1 if successList.include?( result_2 )
    debug("succesCount", succesCount)

    rank =
      if( succesCount >= 2 )
        "成功"
      elsif( succesCount == 1 )
        "部分的成功"
      else
        "失敗"
      end

    return "(1d100<=#{diff_1},#{diff_2}) ＞ #{total}[#{result_1},#{result_2}] ＞ #{rank}"
    #rankIndex = [rankIndex_1, rankIndex_2].max
   # rank = ranks[rankIndex]
    
    #return "(1d100<=#{diff_1},#{diff_2}) ＞ #{total}[#{result_1},#{result_2}] ＞ #{rank}"
  end
  
    def getIsanCheck(command)#不定狂気判定
    #output = 1
    #return output unless(/ISAN/i =~ command)
    total, = roll(1, 10)
    if(total == 1)
    return "不定狂気(1d10) > #{total}:健忘症親しい物のことを最初に忘れる；言語や肉体的な技能は働くが、知的な技能は働かない）"
    elsif(total == 2)
    return "不定狂気(1d10) > #{total}:激しい恐怖症（逃げ出すことはできるが、恐怖の対象はどこに行っても見える）"
    elsif(total == 3)
    return "不定狂気(1d10) > #{total}:幻覚"
    elsif(total == 4)
   return "不定狂気(1d10) > #{total}:奇妙な性的嗜好（露出症、過剰性欲、奇形愛好症など）"
    elsif(total == 5)
    return "不定狂気(1d10) > #{total}:フェティッシュ（探索者はある物、ある種類の物、人物に対し異常なまでに執着する）"
    elsif(total == 6)
    return "不定狂気(1d10) > #{total}:制御不能のチック、震え、あるいは会話や文章で人と交流することができなくなる。 "
    elsif(total == 7)
    return "不定狂気(1d10) > #{total}:心因性視覚障害、心因性聴覚障害、単数あるいは複数の四肢の機能障害"
    elsif(total == 8)
    return "不定狂気(1d10) > #{total}:短時間の心因反応（支離滅裂、妄想、常軌を逸した振る舞い、幻覚など）"
    elsif(total == 9)
    return "不定狂気(1d10) > #{total}:パラノイア"
    elsif(total <= 10)
    return "不定狂気(1d10) > #{total}:強迫観念に取り憑かれた行動（手を洗い続ける、祈る、特定のリズムで歩く、割れ目をまたがない、銃を絶え間なくチェックし続けるなど）"
    
    end
   end
    
    def getTsanCheck(command)#一時狂気判定
        #output = 1
    #return output unless(/TSAN/i =~ command)
   total, = roll(1, 10)
    if(total == 1)
    return "一時狂気(1d10) > #{total}:気絶あるいは金切り声の発作。"
    elsif(total == 2)
    return "一時狂気(1d10) > #{total}:パニック状態で逃げ出す。"
    elsif(total == 3)
    return "一時狂気(1d10) > #{total}:肉体的ヒステリーあるいは感情の噴出（大笑い、大泣きなど）"
    elsif(total == 4)
   return "一時狂気(1d10) > #{total}:早口でぶつぶつ言う意味不明の会話あるいは多弁症（一貫した会話の奔流）"
    elsif(total == 5)
    return "一時狂気(1d10) > #{total}:探索者をその場に釘付けにしてしまうかもしれないような極度の恐怖症。"
    elsif(total == 6)
    return "一時狂気(1d10) > #{total}:殺人癖あるいは自殺癖。"
    elsif(total == 7)
    return "一時狂気(1d10) > #{total}:幻覚あるいは妄想。"
    elsif(total == 8)
    return "一時狂気(1d10) > #{total}:反響動作あるいは反響言語（探索者は周りの者の動作あるいは発言を反復する）"
    elsif(total == 9)
    return "一時狂気(1d10) > #{total}:奇妙なもの、異様なものを食べたがる（泥、粘着質、人肉など）"
    elsif(total <= 10)
    return "一時狂気(1d10) > #{total}:昏迷（胎児のような姿勢をとる、物事を忘れる）。\nあるいは緊張症（我慢することはできるが遺志も興味もない。強制的に単純な行動を取らせることはできるが、自発的に行動することはできない。）"
   
    end
   end
    
    def getDreamCheck(command)#ドリームランド内の狂気
        #output = 1
    #return output unless(/DSAN/i =~ command)
    total, = roll(1, 10)
    if(total == 1)
    return "悪夢(1d10) > #{total}:品物、身に着けている物、体の器官など一つの物が溶けてなくなってしまう。\nあるいはそれらが忌まわしいもの、恐ろしいものに変わる"
    elsif(total == 2)
    return "悪夢(1d10) > #{total}:自由に逃げだすことができなくなる(階段が∞に続いて見えたり、体が突然麻痺を起こす、\n足が地面に釘付けされたり、超スローモーションでしか逃げられない)これは恐怖の対象が居なくなるまで続く"
    elsif(total == 3)
    return "悪夢(1d10) > #{total}:自分の取り囲んでいる環境が突然溶け去ってしまい、自分がまったく別の場所にいる。"
    elsif(total == 4)
   return "悪夢(1d10) > #{total}:夢見人でない仲間の一人が、あるいは近くの植物か動物が、恐ろしい怪物に変身する。"
    else if(total == 5)
    return "悪夢(1d10) > #{total}:古傷、昔かかった病気やケガ、体の不自由などが、突然痛み出す・再発するなど、再び不自由になる"
    elsif(total == 6)
    return "悪夢(1d10) > #{total}:探索者は目が覚める。現実か夢か区別がつかなくなり、混乱する。\n自分の夢をドリームランド内の特定の人物や場所に向かわせることができない。 "
    elsif(total == 7)
    return "悪夢(1d10) > #{total}:対抗表で正気度ポイントの喪失値と探索者のINTを競わせる。\n失敗した場合、探索者はただちに目が覚め、白髪か抜け毛が進行する"
    elsif(total == 8)
    return "悪夢(1d10) > #{total}:対抗表で正気度ポイントの喪失値と探索者のPOWを競わせる。\n失敗した場合、探索者はただちに目が覚め、チック症が起こる。APPあるいはDEXが3ダイス分喪失する場がある。"
    elsif(total == 9)
    return "悪夢(1d10) > #{total}:対抗表で正気度ポイントの喪失値と探索者のCONを競わせる。\n失敗した場合、探索者は軽い心臓発作に襲われ、CON*10を超えた出目が出た場合死ぬ。成功でもCONが1減少する"
    elsif(total <= 10)
    return "悪夢(1d10) > #{total}:KPの選ぶその他適切な効果が起こる。"
    end
   end
 end
 end
