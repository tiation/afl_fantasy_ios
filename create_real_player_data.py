#!/usr/bin/env python3
"""
Create real AFL Fantasy Player URLs file from the provided data
"""

import pandas as pd

def create_real_player_data():
    # Real player data from your list
    players_data = """Harry Morrison	CD_I1000963	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1000963
Lloyd Meek	CD_I1000980	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1000980
James Worpel	CD_I1002222	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1002222
Massimo D'Ambrosio	CD_I1005144	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1005144
James Rowbottom	CD_I1006126	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1006126
Sam Wicks	CD_I1006232	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1006232
Dylan Moore	CD_I1006314	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1006314
Conor Nash	CD_I1007124	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1007124
Joel Amartey	CD_I1008091	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1008091
Tom McCartin	CD_I1008198	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1008198
Will Day	CD_I1008550	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1008550
Finn Maginness	CD_I1009421	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1009421
Justin McInerney	CD_I1011936	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1011936
Chad Warner	CD_I1012014	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1012014
Matt Roberts	CD_I1012210	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1012210
Jack Ginnivan	CD_I1012857	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1012857
James Jordon	CD_I1013409	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1013409
Connor Macdonald	CD_I1017094	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1017094
Corey Warner	CD_I1018424	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1018424
Angus Sheldrick	CD_I1020339	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1020339
Jai Newcombe	CD_I1020895	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1020895
Nick Watson	CD_I1023473	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1023473
Cam Mackenzie	CD_I1023482	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1023482
Tom Hanily	CD_I1027687	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1027687
Josh Weddle	CD_I1027935	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1027935
Dane Rampe	CD_I290307	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I290307
Taylor Adams	CD_I291776	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I291776
Brodie Grundy	CD_I293957	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I293957
Jake Lloyd	CD_I295342	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I295342
Karl Amon	CD_I297354	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I297354
James Sicily	CD_I297566	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I297566
Isaac Heeney	CD_I298539	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I298539
Tom Barrass	CD_I990290	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I990290
Blake Hardwick	CD_I993794	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I993794
Mabior Chol	CD_I994077	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I994077
Lewis Melican	CD_I996743	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I996743
Tom Papley	CD_I996765	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I996765
Will Hayward	CD_I997100	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I997100
Oliver Florent	CD_I998103	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I998103
Josh Battle	CD_I998134	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I998134
Ben Paton	CD_I1004985	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1004985
Nick Blakey	CD_I1006028	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1006028
Braeden Campbell	CD_I1013133	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1013133
Jarman Impey	CD_I296254	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I296254
Jack Scrimshaw	CD_I998114	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I998114
Sam Frost	CD_I293738	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I293738
Lachie Schultz	CD_I1000860	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1000860
Brent Daniels	CD_I1002251	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1002251
Patrick Lipinski	CD_I1003130	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1003130
Jacob Wehr	CD_I1004530	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1004530
Beau McCreery	CD_I1004757	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1004757
Josh Daicos	CD_I1005054	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1005054
Sam Taylor	CD_I1005247	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1005247
Xavier O'Halloran	CD_I1006135	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1006135
Bobby Hill	CD_I1006148	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1006148
Connor Idun	CD_I1008083	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1008083
Isaac Quaynor	CD_I1008089	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1008089
Toby Bedford	CD_I1008139	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1008139
Kieren Briggs	CD_I1008436	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1008436
Jack Buckley	CD_I1009708	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1009708
Reef McInnes	CD_I1013278	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1013278
Callum M. Brown	CD_I1014038	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1014038
Ned Long	CD_I1017124	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1017124
Aaron Cadman	CD_I1019038	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1019038
Edward Allan	CD_I1022915	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1022915
Nick Daicos	CD_I1023261	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1023261
Finn Callaghan	CD_I1023266	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1023266
Max Gruzewski	CD_I1027921	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1027921
James Leake	CD_I1032119	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1032119
Scott Pendlebury	CD_I260257	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I260257
Callan Ward	CD_I280109	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I280109
Steele Sidebottom	CD_I280965	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I280965
Lachlan Keeffe	CD_I290314	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I290314
Jeremy Howe	CD_I291313	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I291313
Brody Mihocek	CD_I291849	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I291849
Stephen Coniglio	CD_I291969	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I291969
Jamie Elliott	CD_I293801	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I293801
Jack Crisp	CD_I293871	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I293871
Lachie Whitfield	CD_I294305	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I294305
Josh Kelly	CD_I296347	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I296347
Daniel McStay	CD_I297504	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I297504
Darcy Cameron	CD_I990291	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I990291
Brayden Maynard	CD_I992010	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I992010
Harry Perryman	CD_I998205	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I998205
Lachie Ash	CD_I1009253	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1009253
Conor Stone	CD_I1015862	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I1015862
Marcus Bontempelli	CD_I297373	https://dfsaustralia.com/afl-fantasy-player-summary/?playerId=CD_I297373"""
    
    # Parse the data
    lines = players_data.strip().split('\n')
    data = []
    
    for line in lines:
        if line.strip():
            parts = line.split('\t')
            if len(parts) >= 3:
                player_name = parts[0].strip()
                player_id = parts[1].strip()
                url = parts[2].strip()
                data.append({
                    'Player': player_name,
                    'playerId': player_id,
                    'url': url
                })
    
    # Create DataFrame
    df = pd.DataFrame(data)
    
    # Save to Excel
    df.to_excel("AFL_Fantasy_Player_URLs.xlsx", index=False)
    
    print(f"✅ Created real AFL_Fantasy_Player_URLs.xlsx with {len(df)} players")
    print("📊 Sample data:")
    print(df.head())
    print(f"\n💯 Ready to scrape {len(df)} AFL Fantasy players!")
    
    return df

if __name__ == "__main__":
    create_real_player_data()
