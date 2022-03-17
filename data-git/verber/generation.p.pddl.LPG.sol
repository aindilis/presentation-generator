
; Version LPG-td-1.0
; Seed 98220514
; Command line: /var/lib/myfrdcsa/codebases/internal/verber/data/planner-library/lpg-td-1.0 -o video/generation.d.pddl -f video/generation.p.pddl -out /var/lib/myfrdcsa/codebases/internal/verber/data/worldmodel/worlds/video/generation.p.pddl.LPG.sol -speed 
; Problem video/generation.p.pddl
; Time 0.00
; Search time 0.00
; Parsing time 0.00
; Mutex time 0.00
; MakeSpan 2.30

0.0003:   (ASSIGN-CLIP-TO-VIDEO-TRACK C2 V1) [0.0000]
0.0005:   (ASSIGN-CLIP-TO-VIDEO-TRACK C1 V2) [0.0000]
0.0008:   (PLAY-VIDEO-CLIP C1 V2) [0.2715]
0.1725:   (EXECUTE-TRANSITION T1-2 C1 C2) [0.1000]
0.2727:   (PLAY-VIDEO-CLIP C2 V1) [0.5300]
0.7030:   (EXECUTE-TRANSITION T2-3 C2 C3) [0.1000]
0.2732:   (ASSIGN-CLIP-TO-VIDEO-TRACK C3 V1) [0.0000]
0.8035:   (UNASSIGN-CLIP-FROM-VIDEO-TRACK C2 V1) [0.0000]
0.8038:   (PLAY-VIDEO-CLIP C3 V1) [1.5000]


