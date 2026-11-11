;;;============================================================================
;;;  RoadPro.lsp  -  Professional Road Builder for AutoCAD
;;;  Version : 3.6                                   Date : 11-Nov-2026
;;;  Developed by https://www.exceltokml.com/
;;;  Chainage inputs accept plain metres (100) or chainage format (0+100).
;;;  RDW / RDT with Both sides : left and right can use different chainages
;;;  and a different fillet radius. Every fillet / taper radius is marked on plan.
;;;----------------------------------------------------------------------------
;;;  COMMANDS
;;;    ROADPRO    (or RDP) ..... build a complete road from a centre line
;;;    ROADREPORT (or RDR) ..... full report of any road built by RoadPro
;;;    ROADRADIUS (or RDRAD) ... add radius / TC / CT labels to a RoadPro road
;;;    ROADSECTIONS (or RDSEC) . add straight-section labels to a RoadPro road
;;;    ROADXSEC (or RDX) ....... CROSS SECTION drawings : typical, at one
;;;                              chainage, or at every chainage interval
;;;    ROADWIDEN (or RDW) ...... LANE WIDENING : extra lane from a start to
;;;                              an end chainage, with taper in / out,
;;;                              straight or curve (reverse-curve) taper,
;;;                              fillet at match points or direct link
;;;    ROADJUNCTION (or RDJ) ... ROAD JUNCTION / TIE-IN : join a new road to an
;;;                              existing RoadPro road, with kerb-return radii,
;;;                              opened edge, corner surface, barricades and
;;;                              turning-area road markings (stop / give way
;;;                              line, STOP word or triangle, turn arrow,
;;;                              broken edge line across the mouth)
;;;    ROADMARK (or RDM) ....... ROAD MARKINGS : yellow edge lines, white double
;;;                              continuous centre line (no median barrier),
;;;                              SLOW before bends, gaps at junctions, broken
;;;                              lane line beside auxiliary lanes, quantities
;;;  v3.1 : turning radius "match existing" or manual; paved shoulder; edge =
;;;         barricades / traffic cones / kerb stone (also in cross section);
;;;         centre = double white line / barricades / cones; junction with
;;;         auxiliary lane (long approach taper, short departure taper) and
;;;         optional splitter island (kerbed or painted).
;;;  v3.2 : signs and markings set out from the Oman Highway Design Standards
;;;         2017, Section 19 (GCC Manual based) : sign plate sizes and warning
;;;         distances by speed limit, yellow warning triangles, yellow/black
;;;         chevrons (black/yellow for road works), red cones with white band,
;;;         L1 / L2 / L2A centre lines by speed, L4 yellow edge lines, L5 broken
;;;         lines, L7 stop line + STOP, L8 give-way lines + triangle, lane
;;;         arrows 5.0 / 7.5 m, delineator posts on curves (spacing by radius),
;;;         sign lower edge 1.5 m. Check against QTCM for projects in Qatar.
;;;    ROADLINE (or RDL) ....... SINGLE LINE : barricades, traffic cones or kerb
;;;                              stone along ANY line / polyline / arc / spline,
;;;                              on the line, offset left / right or both sides
;;;  v3.3 : junction corners use barricades, cones or kerb stone (same as
;;;         the main road or chosen); cones and kerb stone now also follow
;;;         lane widening and road tapers; kerb stone drawn in units.
;;;  v3.4 : CORRIDOR - lanes (from road width / manual / automatic), single
;;;         or dual carriageway, median (flush / raised), sidewalks left and
;;;         right, walkways, drainage provision (open channel / U-channel /
;;;         pipe), utility corridor provision, interlocking paver hatch
;;;         (RP_PAVER, I-shape) - in plan, cross section and report.
;;;         Curve radius editable after the design (RDER) with rebuild;
;;;         rebuild after editing the CL by hand (RDB); targeted corridor
;;;         update (RDC / RDU); alignment checks (short segments, sharp
;;;         bends, self-intersection); keep the original line (build on a
;;;         copy); Civil 3D alignment selection; LandXML 1.2 alignment
;;;         export (RDLX) and import (RDLXI). Lane widening now updates the
;;;         edge markings. Drains / utilities are GEOMETRIC PROVISIONS ONLY.
;;;    ROADCORRIDOR (RDC) ...... lanes / median / sidewalks / drains / utilities
;;;    ROADUPDATE (RDU) ........ regenerate corridor + markings of a road
;;;    ROADEDITRADIUS (RDER) ... change a curve radius after the design
;;;    ROADREBUILD (RDB) ....... rebuild a road from its edited centre line
;;;    ROADLANDXML (RDLX) ...... export the centre line as LandXML 1.2
;;;    ROADLANDXMLIN (RDLXI) ... import LandXML alignments as polylines
;;;    ROADTAPER (or RDT) ...... ROAD TAPER : widen or narrow the road edge
;;;                              from any start to any end chainage; the
;;;                              new width continues to the road end. Add
;;;                              as many tapers as needed, anywhere.
;;;  v3.5 : PERMANENT ADD-IN - load once with APPLOAD, RoadPro copies itself
;;;         to %APPDATA%\RoadPro and joins the Startup Suite (AutoCAD and
;;;         Civil 3D, every profile) - RDINSTALL / RDUNINSTALL, RoadPro menu.
;;;         LIVE UPDATE - edit a road centre line (grips, MOVE, ROTATE,
;;;         STRETCH, PEDIT ...) and the road, corridor, markings, widenings,
;;;         tapers, junctions and roundabouts follow (RDLIVE on / off). Every
;;;         rebuild (RDB / RDER / RDC) now REPLAYS widenings, tapers, junctions
;;;         and roundabouts instead of dropping them.
;;;         JUNCTION STANDARD - Saudi Arabia SHC 301 / MOMRA (AASHTO based) :
;;;         corner radius by road class / design vehicle, auxiliary lane,
;;;         tapers and storage by speed, islands, sight triangles (ISD).
;;;         CORRIDOR AT JUNCTIONS - sidewalks, walkways and drains wrap round
;;;         the kerb returns (and roundabouts) and are hatched; the utility
;;;         corridor of the branch joins the main road one.
;;;         ROUNDABOUTS - FHWA "Roundabouts: An Informational Guide" 2000 :
;;;         Mini, Urban Compact, Urban Single Lane, Urban Double Lane (+ spiral
;;;         marking), Rural Single Lane, Rural Double Lane (+ spiral marking),
;;;         and the 2010 guide (NCHRP 672). RDJ can build a roundabout at the
;;;         junction (asks the radius); RDRB builds one anywhere on a road.
;;;         CONCRETE PAVEMENT - earthwork, stone base, concrete slab, steel
;;;         (dowels, tie bars, mesh) : joints on plan, layers + steel in the
;;;         cross section, quantities in the report (RDPV).
;;;  v3.6 : CLEAN TIE-IN - side roads now start where the kerb returns end;
;;;         ONE mouth surface hatch joins the main road hatch (no overlap,
;;;         no black wedges); shoulder bands and barricades are cut at the
;;;         mouth; the corridor (sidewalk / walkway / drain) strips meet the
;;;         corner pieces; corner hatch pattern follows the through road.
;;;         ROUNDABOUTS - 2-way, 3-way (T, left or right) and 4-way (cross);
;;;         automatic side-road legs (straight, at 90 degrees, any length);
;;;         main road surface, shoulders and barricades are cut at the ring;
;;;         FULL MARKING : edge lines on every path, inner ring line, entry
;;;         arrows, give way lines.
;;;         CURVE EDIT - after a grip edit of a bend the arc is refitted
;;;         tangent at its radius (live update and RDB) : barricades,
;;;         edges and corridor follow cleanly.
;;;         CENTRE LINE MOVE - junction / roundabout heads move with the road
;;;         on every rebuild (RDB / live update).
;;;         CROSS SECTION - drawn only up to the CORRIDOR LIMIT, with
;;;         professional dimensions : component chain with names, roadside /
;;;         carriageway / roadside, corridor width, offset + level table,
;;;         staggered item notes with leaders, architectural ticks.
;;;    ROADROUNDABOUT (RDRB) ... roundabout on a road, with side roads
;;;    ROADPAVEMENT (RDPV) ..... asphalt / concrete pavement of a road
;;;    ROADLIVE (RDLIVE) ....... live update on / off
;;;    ROADPROINSTALL (RDINSTALL) / ROADPROUNINSTALL (RDUNINSTALL)
;;;    ROADHELP (RDHELP) ....... list of all commands
;;;    ROADPRORESET ............ restore all settings to factory defaults
;;;
;;;  WHAT IT BUILDS
;;;    - Centre line (ROAD-CL) with a custom "-- CL --" linetype
;;;    - Left and right road edges at +/- half the road width (ROAD-EDGE)
;;;    - Automatic turning radius at every bend (default 10 m, asked first),
;;;      measured at the CENTRE LINE (default) or at the inner edge
;;;    - Road surface hatch (ROAD-SURFACE)
;;;    - Red / white barricades Left / Right / Centre, black outline
;;;    - Chainage ticks and labels, e.g. CH 0+020 (ROAD-CHAINAGE)
;;;    - RADIUS ON PLAN: radius line with arrow + R value at every bend,
;;;      centre mark, TC / CT ticks with chainage, curve data label
;;;      (R inner, R CL, arc length, deflection, area) (ROAD-CURVE)
;;;    - STRAIGHT SECTIONS ON PLAN: S1, S2 ... extent bar with end ticks,
;;;      length, area, bearing, from / to chainage (ROAD-SECTION)
;;;    - Report includes a ROAD SECTIONS table: every straight and curve
;;;      with chainage, length, edge lengths, area, bearing / radius
;;;    - SIGNAGE (traffic keeps right), each sign with post, plate facing
;;;      traffic, leader, symbol and ID tag SG-01, SG-02 ... :
;;;        Road works ahead (+ plate), speed limit, bend ahead left/right,
;;;        STOP or GIVE WAY at tie-ins, NO ENTRY (one-way), KEEP RIGHT at
;;;        the median, chevron boards on bends, ROAD CLOSED boards,
;;;        lane direction arrows on the carriageway (ROAD-MARKING)
;;;    - CROSS SECTIONS: crossfall / camber, pavement layers with
;;;      thickness, shoulders, subgrade, barricade profiles WITH HEIGHT
;;;      (water-filled or New Jersey), sign post with clearance height
;;;      and footing, centre line, crossfall arrows, full dimensions
;;;    - SIGN SCHEDULE (ID, sign, chainage, side, facing, E, N) and a
;;;      SIGN LEGEND with symbols in the report
;;;    - ROAD ENDS: tie-in line with existing road + coordinates, or
;;;      road-closed barricade + ROAD CLOSED sign (ROAD-TIEIN)
;;;    - REPORT: tables in the drawing + Excel (CSV) file next to the DWG
;;;        * General, geometry, barricades, signs, road ends, chainage
;;;        * Curve data   : TC / CT chainage, radius, arc, deflection, E/N
;;;        * Setting-out  : E/N of centre line, left & right edge at every
;;;                         chainage, TC, CT, start and end
;;;    - Whole road = ONE undo step. Settings are remembered.
;;;
;;;  INSTALL : run Install_RoadPro.bat (add-in bundle, loads by itself in
;;;            AutoCAD / Civil 3D 2013+, every profile), or APPLOAD -> select
;;;            RoadPro.lsp -> Load ONE time (Startup Suite self-install)
;;;  NEEDS   : Full AutoCAD / Civil 3D / Map 3D 2013 or newer (not LT)
;;;  INPUT   : All sizes are typed in METERS. For mm drawings choose
;;;            "Millimeters" in the dialog - RoadPro scales everything.
;;;============================================================================
(vl-load-com)

(setq *rp:ver* "3.6")

(setq *rp:defaults*
  '(("rname"  . "ROAD-01") ("width"  . "7.30")  ("radius" . "10.0")  ("rref"   . "0")
    ("units"  . "0")       ("mode"   . "0")
    ("bl"     . "1")       ("br"     . "1")     ("bc"     . "0")
    ("blen"   . "2.00")    ("bwid"   . "0.50")  ("bgap"   . "0.50")
    ("sspeed" . "1")       ("speed"  . "30")    ("swarn"  . "1")     ("warnd"  . "30")
    ("schev"  . "1")       ("twoway" . "1")     ("signsz" . "2.0")
    ("hatch"  . "1")       ("hpat"   . "SOLID") ("hscl"   . "1.0")   ("cltext" . "1")
    ("ch"     . "1")       ("chint"  . "20")    ("chst"   . "0")     ("txth"   . "1.0")
    ("endst"  . "0")       ("endfn"  . "0")     ("report" . "1")
    ("rlab"   . "1")       ("slab"   . "1")
    ("srw"    . "1")       ("skr"    . "1")     ("sarr"   . "1")     ("jctl"   . "0")
    ("ssp"    . "15")      ("xsec"   . "1")     ("mark"   . "1")
    ("rmode"  . "0")       ("etype"  . "0")     ("ctype"  . "0")     ("slow"   . "0")
    ("cmark"  . "0")       ("sauto"  . "1")     ("sset"   . "1")     ("deli"   . "1")))

(setq *rp:keys* (vl-remove "bc" (mapcar 'car *rp:defaults*)))   ; "bc" comes from the Centre popup

;; Cross-section settings (own dialog)
(setq *rp:xdefaults*
  '(("xmode"  . "0")    ("xch"    . "0")     ("xint"   . "20")
    ("xcf"    . "2.5")  ("xcamb"  . "0")     ("xverge" . "1.0")
    ("xl1n"   . "ASPHALT WEARING COURSE")    ("xl1t"   . "0.05")
    ("xl2n"   . "AGGREGATE BASE COURSE")     ("xl2t"   . "0.20")
    ("xl3n"   . "GRANULAR SUB-BASE")         ("xl3t"   . "0.15")
    ("xbtype" . "0")    ("xbh"    . "1.00")
    ("xsign"  . "1")    ("xsclr"  . "1.50")  ("xsplate" . "0.90")))
(setq *rp:xkeys*    (mapcar 'car *rp:xdefaults*)
      *rp:defaults* (append *rp:defaults* *rp:xdefaults*))

;; Lane widening settings (own dialog)
(setq *rp:wdefaults*
  '(("wside"  . "1")    ("wwid"   . "3.65")  ("wst"    . "100")   ("wen"   . "200")
    ("wtin"   . "30")   ("wtout"  . "30")    ("wtype"  . "0")     ("wmatch" . "0")
    ("wrad"   . "30")   ("wbar"   . "1")     ("warr"   . "1")     ("wlab"   . "1")
    ("wdiff"  . "0")    ("wwid2"  . "3.65")  ("wst2"   . "100")   ("wen2"  . "200")
    ("wtin2"  . "30")   ("wtout2" . "30")    ("wrad2"  . "30")))
(setq *rp:wkeys*    (mapcar 'car *rp:wdefaults*)
      *rp:defaults* (append *rp:defaults* *rp:wdefaults*))

;; Road taper settings (own dialog)
(setq *rp:tdefaults*
  '(("tside"  . "2")    ("tst"    . "100")   ("ten"    . "130")   ("tshift" . "1.00")
    ("ttype"  . "0")    ("tmatch" . "0")     ("trad"   . "30")    ("tbar"   . "1")
    ("tlab"   . "1")    ("tdiff"  . "0")     ("tst2"   . "100")   ("ten2"   . "130")
    ("tshift2" . "1.00") ("trad2"  . "30")))
(setq *rp:tkeys*    (mapcar 'car *rp:tdefaults*)
      *rp:defaults* (append *rp:defaults* *rp:tdefaults*))

;; Road junction settings (own dialog)
(setq *rp:jdefaults*
  '(("jname" . "ROAD-02") ("jwid" . "7.30") ("jmode" . "0") ("jrad" . "10.0") ("jbar" . "1")
    ("jmark" . "1") ("jcorner" . "0")
    ("jaux" . "1") ("jauxw" . "3.65") ("jlong" . "60") ("jshort" . "30") ("jstore" . "30")
    ("jisl" . "0") ("jislw" . "1.5") ("jisll" . "15")
    ("jtype" . "0") ("jstd" . "0") ("jcls" . "2") ("jsight" . "0")))
(setq *rp:jkeys*    (append (mapcar 'car *rp:jdefaults*) '("jctl" "rbstd" "rbr"))
      *rp:defaults* (append *rp:defaults* *rp:jdefaults*))

;;----------------------------------------------------------------------------
;;  Dialog definition (written to a temp file at run time - single file plugin)
;;----------------------------------------------------------------------------
(setq *rp:dcl*
 (list
  "roadpro : dialog {"
  "  label = \"ROAD PRO  -  Road Builder for AutoCAD / Civil 3D  v3.6\";"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Road Geometry\";"
  "      : edit_box   { key = \"rname\";  label = \"Road name / ID:\";      edit_width = 14; }"
  "      : edit_box   { key = \"width\";  label = \"Road width (m):\";      edit_width = 14; }"
  "      : popup_list { key = \"rmode\";  label = \"Turning radius:\";      edit_width = 24; }"
  "      : edit_box   { key = \"radius\"; label = \"Manual radius (m):\";   edit_width = 14; }"
  "      : popup_list { key = \"rref\";   label = \"Radius measured at:\";  edit_width = 24; }"
  "      : popup_list { key = \"units\";  label = \"Drawing units:\";       edit_width = 24; }"
  "      : popup_list { key = \"mode\";   label = \"Centre line input:\";   edit_width = 24; }"
  "      : toggle     { key = \"keep\";   label = \"Keep the original line (build on a copy)\"; }"
  "      : toggle     { key = \"rlab\";   label = \"Show radius, TC / CT and curve data on plan\"; }"
  "      : toggle     { key = \"slab\";   label = \"Show straight sections (S1, S2...) on plan\"; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Road Edge and Centre\";"
  "      : row {"
  "        : toggle { key = \"bl\"; label = \"Left edge\"; }"
  "        : toggle { key = \"br\"; label = \"Right edge\"; }"
  "      }"
  "      : popup_list { key = \"etype\"; label = \"Edge:\";   edit_width = 24; }"
  "      : popup_list { key = \"ctype\"; label = \"Centre:\"; edit_width = 24; }"
  "      : edit_box { key = \"blen\"; label = \"Unit length / cone spacing (m):\"; edit_width = 6; }"
  "      : edit_box { key = \"bwid\"; label = \"Unit / cone / kerb width (m):\";   edit_width = 6; }"
  "      : edit_box { key = \"bgap\"; label = \"Paved shoulder (m):\";             edit_width = 6; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Signs and Markings\";"
  "      : row { : toggle { key = \"sspeed\"; label = \"Speed limit\"; }"
  "              : edit_box { key = \"speed\"; label = \"km/h:\"; edit_width = 5; } }"
  "      : row { : toggle { key = \"swarn\"; label = \"Bend ahead\"; }"
  "              : edit_box { key = \"warnd\"; label = \"before (m):\"; edit_width = 5; } }"
  "      : toggle     { key = \"srw\";    label = \"Road works ahead (with plate)\"; }"
  "      : toggle     { key = \"schev\";  label = \"Chevron boards on bends\"; }"
  "      : toggle     { key = \"skr\";    label = \"Keep right at median\"; }"
  "      : toggle     { key = \"sarr\";   label = \"Lane direction arrows\"; }"
  "      : popup_list { key = \"jctl\";   label = \"At tie-in:\"; edit_width = 16; }"
  "      : toggle     { key = \"twoway\"; label = \"Two-way traffic (signs both ways)\"; }"
  "      : toggle     { key = \"sauto\";  label = \"Sizes and distances by speed (HDS)\"; }"
  "      : popup_list { key = \"sset\";   label = \"Sign set:\"; edit_width = 18; }"
  "      : row { : edit_box { key = \"signsz\"; label = \"Symbol (m):\"; edit_width = 5; }"
  "              : edit_box { key = \"ssp\"; label = \"Spacing (m):\"; edit_width = 5; } }"
  "    }"
  "  }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Surface and Centre Line\";"
  "      : toggle   { key = \"hatch\";  label = \"Hatch road surface\"; }"
  "      : edit_box { key = \"hpat\";   label = \"Hatch pattern:\";             edit_width = 10; }"
  "      : edit_box { key = \"hscl\";   label = \"Pattern scale (not SOLID):\"; edit_width = 10; }"
  "      : toggle   { key = \"cltext\"; label = \"Show CL text in centre line\"; }"
  "      : toggle   { key = \"mark\";   label = \"Road markings (centre + edge lines)\"; }"
  "      : popup_list { key = \"cmark\";  label = \"Centre marking:\"; edit_width = 22; }"
  "      : toggle   { key = \"slow\";   label = \"SLOW markings before bends\"; }"
  "      : toggle   { key = \"deli\";   label = \"Delineator posts on curves\"; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Chainage\";"
  "      : toggle   { key = \"ch\";    label = \"Add chainage ticks and labels\"; }"
  "      : edit_box { key = \"chint\"; label = \"Interval (m):\";        edit_width = 8; }"
  "      : edit_box { key = \"chst\";  label = \"Start chainage (m):\";  edit_width = 8; }"
  "      : edit_box { key = \"txth\";  label = \"Text height (m):\";     edit_width = 8; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Road Ends and Report\";"
  "      : popup_list { key = \"endst\"; label = \"Start end:\";  edit_width = 26; }"
  "      : popup_list { key = \"endfn\"; label = \"Finish end:\"; edit_width = 26; }"
  "      : toggle     { key = \"report\"; label = \"Report tables + Excel (CSV) file\"; }"
  "      : toggle     { key = \"xsec\";   label = \"Typical cross section drawing\"; }"
  "    }"
  "  }"
  "  : row {"
  "    : button { key = \"corr\"; label = \"Lanes, median, sidewalks, drains, utilities...\"; width = 44; fixed_width = true; }"
  "    : text   { key = \"csum\"; width = 80; }"
  "  }"
  "  : row {"
  "    : button { key = \"pave\"; label = \"Pavement : asphalt / concrete...\"; width = 44; fixed_width = true; }"
  "    : text   { key = \"psum\"; width = 80; }"
  "  }"
  "  : text { label = \"Developed by https://www.exceltokml.com/\"; alignment = right; }"
  "  ok_cancel;"
  "  errtile;"
  "}"))

;;----------------------------------------------------------------------------
;;  Settings (remembered between sessions)
;;----------------------------------------------------------------------------
(defun rp:val (k / v)
  (setq v (getenv (strcat "RoadPro_" k)))
  (if (and v (/= v "")) v (cdr (assoc k *rp:defaults*))))

(defun rp:set (k v) (setenv (strcat "RoadPro_" k) v))

;; Number from text : plain metres "100" or chainage format "0+100" / "1+250.5"
(defun rp:dist (s / p a b)
  (if s (setq s (vl-string-trim " " s)))
  (if (and s (= (substr s 1 1) "+")) (setq s (substr s 2)))
  (if (and s (setq p (vl-string-search "+" s)) (> p 0))
    (if (and (setq a (distof (vl-string-trim " " (substr s 1 p)) 2))
             (setq b (distof (vl-string-trim " " (substr s (+ p 2))) 2)))
      (+ (* a 1000.0) b))
    (if s (distof (vl-string-trim " " s) 2))))

(defun rp:num (k / v)
  (if (setq v (rp:dist (rp:val k))) v (rp:dist (cdr (assoc k *rp:defaults*)))))

(defun rp:on (k) (= (rp:val k) "1"))

;;----------------------------------------------------------------------------
;;  Start / finish / error handling
;;----------------------------------------------------------------------------
(defun rp:start ()
  (setq *rp:doc*    (vla-get-ActiveDocument (vlax-get-acad-object))
        *rp:olderr* *error*
        *error*     rp:error
        *rp:busy*   T
        *rp:ucs*    nil
        *rp:sv*     (mapcar '(lambda (v) (cons v (getvar v)))
                            '("CMDECHO" "PLINETYPE" "PLINEWID" "FILLETRAD" "PEDITACCEPT" "OSMODE")))
  (vla-StartUndoMark *rp:doc*)
  (setq *rp:mk0* (entlast) *rp:cset* nil *rp:cov* nil *rp:xc* nil *rp:lanes* nil *rp:cinx* nil)
  (setvar "CMDECHO" 0))

(defun rp:finish ()
  (setq *rp:busy* nil)
  (if *rp:ucs*
    (progn
      (setq *rp:ucs* nil)
      (if command-s (command-s "_.UCS" "_P") (vl-cmdf "_.UCS" "_P"))))
  (foreach p *rp:sv* (vl-catch-all-apply 'setvar (list (car p) (cdr p))))
  (setq *rp:sv* nil)
  (if *rp:doc* (vl-catch-all-apply 'vla-EndUndoMark (list *rp:doc*)))
  (setq *error* *rp:olderr*)
  (princ))

(defun rp:error (msg)
  (if (and msg (not (wcmatch (strcase msg T) "*break*,*cancel*,*exit*,*quit*")))
    (princ (strcat "\n** RoadPro error: " msg " **  (type U to undo)")))
  (rp:finish))

(defun rp:space ()
  (setq *rp:spc* (if (and (= (getvar "TILEMODE") 0) (= (getvar "CVPORT") 1))
                   (vla-get-PaperSpace *rp:doc*)
                   (vla-get-ModelSpace *rp:doc*))))

(defun rp:world ()
  (if (= (getvar "WORLDUCS") 0) (progn (command "_.UCS" "_W") (setq *rp:ucs* T))))

;;----------------------------------------------------------------------------
;;  Dialog
;;----------------------------------------------------------------------------
(defun rp:fill (k lst) (start_list k) (mapcar 'add_list lst) (end_list))

(defun rp:dlg-modes (/ b)
  (setq b (if (or (= (get_tile "bl") "1") (= (get_tile "br") "1") (/= (get_tile "ctype") "0")) 0 1))
  (foreach k '("blen" "bwid") (mode_tile k b))
  (mode_tile "etype" (if (or (= (get_tile "bl") "1") (= (get_tile "br") "1")) 0 1))
  (foreach k '("radius" "rref") (mode_tile k (if (= (get_tile "rmode") "1") 0 1)))
  (foreach k '("hpat" "hscl") (mode_tile k (if (= (get_tile "hatch") "1") 0 1)))
  (foreach k '("chint" "chst" "txth") (mode_tile k (if (= (get_tile "ch") "1") 0 1)))
  (mode_tile "width" (if (= (rp:val "clmode") "1") 1 0))
  (mode_tile "keep" (if (= (get_tile "mode") "1") 0 1))
  (mode_tile "speed" (if (= (get_tile "sspeed") "1") 0 1))
  (mode_tile "warnd" (if (and (= (get_tile "swarn") "1") (/= (get_tile "sauto") "1")) 0 1)))

(defun rp:dlg-accept (/ bad v)
  ;; (key  name  0=must be > 0 / 1=may be zero)
  (foreach k '(("width"  "Road width"        0) ("radius" "Turning radius"    1)
               ("blen"   "Unit length"       0) ("bwid"   "Unit width"        0)
               ("bgap"   "Paved shoulder"    1) ("speed"  "Speed limit"       0)
               ("warnd"  "Warning distance"  1) ("signsz" "Sign symbol size"  0)
               ("ssp"    "Sign spacing"      0)
               ("hscl"   "Pattern scale"     0) ("chint"  "Chainage interval" 0)
               ("chst"   "Start chainage"    1) ("txth"   "Text height"       0))
    (if (not bad)
      (progn
        (setq v (rp:dist (get_tile (car k))))
        (if (or (null v) (if (= (caddr k) 1) (< v 0.0) (<= v 0.0)))
          (setq bad k)))))
  (if bad
    (progn
      (set_tile "error" (strcat (cadr bad)
                                (if (= (caddr bad) 1)
                                  " must be zero or a positive number."
                                  " must be a number greater than zero.")))
      (mode_tile (car bad) 2))
    (progn
      (if (= (vl-string-trim " " (get_tile "hpat")) "") (set_tile "hpat" "SOLID"))
      (if (= (vl-string-trim " " (get_tile "rname")) "") (set_tile "rname" "ROAD-01"))
      (foreach k *rp:keys* (if (get_tile k) (rp:set k (get_tile k))))
      (rp:set "bc" (if (= (get_tile "ctype") "0") "0" "1"))
      (done_dialog 1))))

(defun rp:dialog (/ fn f id res)
  (setq fn (vl-filename-mktemp "roadpro.dcl"))
  (if (setq f (open fn "w"))
    (progn
      (foreach l *rp:dcl* (write-line l f))
      (close f)
      (setq id (load_dialog fn))
      (if (and id (not (minusp id)) (new_dialog "roadpro" id))
        (progn
          (rp:fill "rref"   '("Centre line (CL)" "Inner edge (kerb line)"))
          (rp:fill "rmode"  '("Match existing (keep CL as drawn)" "Manual radius at every bend"))
          (rp:fill "etype"  '("Barricades (red / white)" "Traffic cones" "Kerb stone"))
          (rp:fill "ctype"  '("Centre line markings (no barrier)" "Barricades (red / white)" "Traffic cones"))
          (rp:fill "sset"   '("Permanent" "Temporary (road works)"))
          (rp:fill "cmark"  '("Standard L1 / L2 / L2A by speed" "Double continuous white" "Single continuous L2A"))
          (rp:fill "units"  '("Meters  (1 unit = 1 m)" "Millimeters  (1 unit = 1 mm)"))
          (rp:fill "mode"   '("Pick points (draw new)" "Select existing Line/Pline/Arc"))
          (rp:fill "endst"  '("Tie-in line (existing road)" "Road closed (barricade+sign)" "None"))
          (rp:fill "endfn"  '("Tie-in line (existing road)" "Road closed (barricade+sign)" "None"))
          (rp:fill "jctl"   '("STOP sign" "GIVE WAY sign" "No sign"))
          (foreach k *rp:keys* (set_tile k (rp:val k)))
          (rp:dlg-modes)
          (rp:main-corr-tiles)
          (rp:main-pave-tiles)
          (action_tile "pave" "(rp:main-pave)")
          (foreach k '("bl" "br" "ctype" "rmode" "hatch" "ch" "sspeed" "swarn" "sauto" "mode")
            (action_tile k "(rp:dlg-modes)"))
          (action_tile "corr" "(rp:main-corr)")
          (action_tile "accept" "(rp:dlg-accept)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq res (if (= (start_dialog) 1) 'ok 'cancel)))
        (setq res 'fail))
      (if (and id (not (minusp id))) (unload_dialog id))
      (vl-file-delete fn))
    (setq res 'fail))
  res)

;; Command-line fallback (only if the dialog cannot be shown)
(defun rp:cmdline (/ v)
  (initget 6)
  (if (setq v (getdist (strcat "\nRoad width in meters <" (rp:val "width") ">: ")))
    (rp:set "width" (rtos v 2 3)))
  (initget 4)
  (if (setq v (getdist (strcat "\nTurning radius in meters, 0 = none <" (rp:val "radius") ">: ")))
    (rp:set "radius" (rtos v 2 3))))

;;----------------------------------------------------------------------------
;;  Layers and linetypes
;;----------------------------------------------------------------------------
(defun rp:mklayer (name col lt lw / lay clr new)
  (setq new (not (tblsearch "LAYER" name))
        lay (vla-Add (vla-get-Layers *rp:doc*) name))
  (if new
    (progn
      (setq clr (vla-get-TrueColor lay))
      (if (listp col)
        (vla-SetRGB clr (car col) (cadr col) (caddr col))
        (vla-put-ColorIndex clr col))
      (vla-put-TrueColor lay clr)
      (if (and lt (tblsearch "LTYPE" lt)) (vla-put-Linetype lay lt))
      (if lw (vla-put-Lineweight lay lw))))
  (vl-catch-all-apply 'vla-put-Lock    (list lay :vlax-false))
  (vl-catch-all-apply 'vla-put-LayerOn (list lay :vlax-true))
  (vl-catch-all-apply 'vla-put-Freeze  (list lay :vlax-false))
  lay)

(defun rp:layers ()
  (rp:mklayer "ROAD-CL"              '(255 0 0)     "ROAD_CL2" 18)
  (rp:mklayer "ROAD-EDGE"            7              nil        35)
  (rp:mklayer "ROAD-SURFACE"         8              nil        0)
  (rp:mklayer "ROAD-BARRIER-RED"     '(255 0 0)     nil        0)
  (rp:mklayer "ROAD-BARRIER-WHITE"   '(255 255 255) nil        0)
  (rp:mklayer "ROAD-BARRIER-OUTLINE" '(0 0 0)       nil        25)
  (rp:mklayer "ROAD-CHAINAGE"        3              nil        18)
  (rp:mklayer "ROAD-SIGN"            '(0 0 0)       nil        25)
  (rp:mklayer "ROAD-SIGN-RED"        '(255 0 0)     nil        0)
  (rp:mklayer "ROAD-SIGN-WHITE"      '(255 255 255) nil        0)
  (rp:mklayer "ROAD-TIEIN"           6              "ROAD_TIE" 35)
  (rp:mklayer "ROAD-REPORT"          7              nil        18)
  (rp:mklayer "ROAD-CURVE"           5              nil        18)
  (rp:mklayer "ROAD-SECTION"         30             nil        18)
  (rp:mklayer "ROAD-SIGN-BLUE"       '(0 82 164)    nil        0)
  (rp:mklayer "ROAD-MARKING"         8              nil        0)
  (rp:mklayer "ROAD-MARKING-FILL"    '(255 255 255) nil        0)
  (rp:mklayer "ROAD-XSEC"            7              nil        35)
  (rp:mklayer "ROAD-XSEC-THIN"       8              nil        13)
  (rp:mklayer "ROAD-XSEC-DIM"        3              nil        13)
  (rp:mklayer "ROAD-XSEC-LIMIT"      6              "ROAD_TIE" 25)
  (rp:mklayer "ROAD-XSEC-TEXT"       7              nil        18)
  (rp:mklayer "ROAD-XSEC-L1"         '(64 64 64)    nil        0)
  (rp:mklayer "ROAD-XSEC-L2"         '(181 140 90)  nil        0)
  (rp:mklayer "ROAD-XSEC-L3"         '(214 196 150) nil        0)
  (rp:mklayer "ROAD-XSEC-SHLD"       '(228 218 196) nil        0)
  (rp:mklayer "ROAD-XSEC-CONC"       '(170 170 170) nil        0)
  (rp:mklayer "ROAD-WIDENING"        40             nil        18)
  (rp:mklayer "ROAD-JUNCTION"        4              nil        18)
  (rp:mklayer "ROAD-SHOULDER"        '(110 116 122) nil        0)
  (rp:mklayer "ROAD-CONE"            '(225 25 25)   nil        0)
  (rp:mklayer "ROAD-CONE-BAND"       '(255 255 255) nil        0)
  (rp:mklayer "ROAD-SIGN-YELLOW"     '(255 210 0)   nil        0)
  (rp:mklayer "ROAD-DELINEATOR"      '(255 255 255) nil        13)
  (rp:mklayer "ROAD-KERB"            '(190 190 190) nil        0)
  (rp:mklayer "ROAD-MARKING-YELLOW"  '(255 204 0)   nil        0)
  (rp:mklayer "ROAD-ISLAND"          '(160 160 160) nil        25)
  (rp:mklayer "ROAD-MEDIAN"          '(118 150 92)  nil        0)
  (rp:mklayer "ROAD-MEDIAN-KERB"     '(190 190 190) nil        25)
  (rp:mklayer "ROAD-SIDEWALK"        '(201 162 122) nil        18)
  (rp:mklayer "ROAD-WALKWAY"         '(216 180 142) nil        18)
  (rp:mklayer "ROAD-DRAIN"           '(47 127 208)  nil        25)
  (rp:mklayer "ROAD-UTILITY"         '(138 79 192)  "ROAD_TIE" 18)
  (rp:mklayer "ROAD-ROUNDABOUT"      4              nil        18)
  (rp:mklayer "ROAD-RB-ISLAND"       '(96 140 70)   nil        0)
  (rp:mklayer "ROAD-RB-APRON"        '(205 188 150) nil        0)
  (rp:mklayer "ROAD-SIGHT"           140            "ROAD_TIE" 13)
  (rp:mklayer "ROAD-CONC-JOINT"      '(90 90 90)    nil        18)
  (rp:mklayer "ROAD-XSEC-PCC"        '(200 200 195) nil        0)
  (rp:mklayer "ROAD-XSEC-EARTH"      '(150 110 70)  nil        0)
  (rp:mklayer "ROAD-XSEC-STEEL"      '(220 30 30)   nil        25))

;; Custom linetypes, defined in meters (scaled automatically for mm drawings)
(defun rp:linetypes (/ lts fn f)
  (setq lts (vla-get-Linetypes *rp:doc*))
  (if (not (and (tblsearch "LTYPE" "ROAD_CL") (tblsearch "LTYPE" "ROAD_CL2")
                (tblsearch "LTYPE" "ROAD_TIE")))
    (progn
      (setq fn (strcat (getvar "TEMPPREFIX") "roadpro.lin"))
      (if (setq f (open fn "w"))
        (progn
          (foreach l '("*ROAD_CL,Road centre line ---- CL ---- CL ----"
                       "A,10,-1.2,[\"CL\",STANDARD,S=0.8,U=0.0,X=-0.7,Y=-0.4],-1.0"
                       "*ROAD_CL2,Road centre line ____ . ____ . ____"
                       "A,6,-1,1,-1"
                       "*ROAD_TIE,Tie-in line __ __ __ __"
                       "A,1.5,-0.75")
            (write-line l f))
          (close f)
          (foreach n '("ROAD_CL" "ROAD_CL2" "ROAD_TIE")
            (if (not (tblsearch "LTYPE" n))
              (vl-catch-all-apply 'vla-Load (list lts n fn)))))))))

(defun rp:cl-ltype (/ n fn)
  (setq n (if (rp:on "cltext") "ROAD_CL" "ROAD_CL2"))
  (cond
    ((tblsearch "LTYPE" n) n)
    ((tblsearch "LTYPE" "ROAD_CL2") "ROAD_CL2")
    (T
     (if (and (not (tblsearch "LTYPE" "CENTER")) (setq fn (findfile "acadiso.lin")))
       (vl-catch-all-apply 'vla-Load (list (vla-get-Linetypes *rp:doc*) "CENTER" fn)))
     (if (tblsearch "LTYPE" "CENTER") "CENTER" "Continuous"))))

;;----------------------------------------------------------------------------
;;  Geometry helpers
;;----------------------------------------------------------------------------
;; Point at distance d along the curve, shifted sideways by off (+ = left)
(defun rp:offpt (cl d off / par p dv l)
  (setq d   (max 0.0 (min d *rp:len*))
        par (vlax-curve-getParamAtDist cl d))
  (if (null par)
    (setq par (if (< d (* 0.5 *rp:len*))
                (vlax-curve-getStartParam cl)
                (vlax-curve-getEndParam cl))))
  (setq p  (vlax-curve-getPointAtParam cl par)
        dv (vlax-curve-getFirstDeriv cl par)
        l  (distance '(0.0 0.0) (list (car dv) (cadr dv))))
  (if (< l 1e-12) (setq l 1.0))
  (list (- (car p)  (* off (/ (cadr dv) l)))
        (+ (cadr p) (* off (/ (car dv) l)))))

;; Local frame at distance d : (point  left-normal  tangent)
(defun rp:frame (cl d / p q n)
  (setq p (rp:offpt cl d 0.0)
        q (rp:offpt cl d 1.0)
        n (list (- (car q) (car p)) (- (cadr q) (cadr p))))
  (list p n (list (cadr n) (- (car n)))))

;; Point in a frame: s along the left normal, u along the tangent
(defun rp:loc (f s u)
  (list (+ (car (car f))  (* s (car (cadr f)))  (* u (car (caddr f))))
        (+ (cadr (car f)) (* s (cadr (cadr f))) (* u (cadr (caddr f))))))

;; Scale, rotate and move a list of 2D points
(defun rp:xf (pts c a s)
  (mapcar '(lambda (p)
             (list (+ (car c)  (* s (- (* (car p) (cos a)) (* (cadr p) (sin a)))))
                   (+ (cadr c) (* s (+ (* (car p) (sin a)) (* (cadr p) (cos a)))))))
          pts))

(defun rp:xf1 (p c s) (car (rp:xf (list p) c 0.0 s)))

(defun rp:p3 (p z) (vlax-3d-point (list (car p) (cadr p) z)))

(defun rp:objarr (lst)
  (vlax-make-variant
    (vlax-safearray-fill
      (vlax-make-safearray vlax-vbObject (cons 0 (1- (length lst))))
      lst)))

;; vl = list of (point bulge)
(defun rp:mkpl (vl lay elev closed / e)
  (setq e (entmakex
            (append
              (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity") (cons 8 lay)
                    '(100 . "AcDbPolyline") (cons 90 (length vl))
                    (cons 70 (if closed 1 0)) (cons 38 elev))
              (apply 'append
                     (mapcar '(lambda (v) (list (cons 10 (car v)) (cons 42 (cadr v)))) vl)))))
  (if e (vlax-ename->vla-object e)))

(defun rp:poly (pts lay elev) (rp:mkpl (mapcar '(lambda (p) (list p 0.0)) pts) lay elev T))

;; Open polyline with widths : vl = list of (point start-width end-width)
(defun rp:mkwpl (vl lay elev)
  (entmakex
    (append
      (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity") (cons 8 lay)
            '(100 . "AcDbPolyline") (cons 90 (length vl)) '(70 . 0) (cons 38 elev))
      (apply 'append
             (mapcar '(lambda (v) (list (cons 10 (car v)) (cons 40 (cadr v))
                                        (cons 41 (caddr v)) '(42 . 0.0)))
                     vl)))))

(defun rp:pldata (o / co pts bl i)
  (setq co (vlax-safearray->list (vlax-variant-value (vla-get-Coordinates o))) i 0)
  (while co (setq pts (cons (list (car co) (cadr co)) pts) co (cddr co)))
  (setq pts (reverse pts))
  (repeat (length pts) (setq bl (cons (vla-GetBulge o i) bl) i (1+ i)))
  (list pts (reverse bl)))

;; Closed boundary = edge 1 forward + edge 2 backward (arcs kept exact)
(defun rp:bnd-verts (o1 o2 / d1 d2)
  (setq d1 (rp:pldata o1) d2 (rp:pldata o2))
  (mapcar 'list
          (append (car d1) (reverse (car d2)))
          (append (reverse (cons 0.0 (cdr (reverse (cadr d1)))))
                  (mapcar '- (cdr (reverse (cadr d2))))
                  '(0.0))))

(defun rp:offset (o d / r)
  (setq r (vl-catch-all-apply 'vla-Offset (list o d)))
  (if (vl-catch-all-error-p r) nil (vlax-safearray->list (vlax-variant-value r))))

(defun rp:props (o lay lt lts / c)
  (vla-put-Layer o lay)
  (setq c (vla-get-TrueColor o))
  (vla-put-ColorMethod c acColorMethodByLayer)
  (vla-put-TrueColor o c)
  (vla-put-Linetype o lt)
  (vla-put-LinetypeScale o lts)
  (vla-put-Lineweight o acLnWtByLayer)
  (vl-catch-all-apply 'vla-put-ConstantWidth (list o 0.0)))

(defun rp:newhatch (pat asc elev / a h)
  (setq a (if asc :vlax-true :vlax-false)
        h (vl-catch-all-apply 'vla-AddHatch
            (list *rp:spc* acHatchPatternTypePreDefined pat a)))
  (if (vl-catch-all-error-p h)
    (progn
      (princ (strcat "\nHatch pattern \"" pat "\" not found - using SOLID."))
      (setq h (vla-AddHatch *rp:spc* acHatchPatternTypePreDefined "SOLID" a))))
  (vla-put-Elevation h elev)
  h)

;; Solid fill inside outer object (optionally minus inner object)
(defun rp:solidfill (outer inner lay elev / h)
  (setq h (rp:newhatch "SOLID" T elev))
  (vla-put-Layer h lay)
  (vla-AppendOuterLoop h (rp:objarr (list outer)))
  (if inner (vla-AppendInnerLoop h (rp:objarr (list inner))))
  (vla-Evaluate h)
  (setq *rp:hatches* (cons h *rp:hatches*))
  h)

(defun rp:text (str pt h lay elev / tx)
  (setq tx (vla-AddText *rp:spc* str (rp:p3 pt elev) h))
  (vla-put-Alignment tx acAlignmentMiddleCenter)
  (vla-put-TextAlignmentPoint tx (rp:p3 pt elev))
  (vla-put-Layer tx lay)
  tx)

(defun rp:toback (objs / ss)
  (setq ss (ssadd))
  (foreach o objs (ssadd (vlax-vla-object->ename o) ss))
  (if (> (sslength ss) 0) (command "_.DRAWORDER" ss "" "_B")))

;; Curves (arc segments) of a polyline : list of
;; (dist-start dist-end radius deflection direction(+1 left/-1 right) TC-point CT-point)
(defun rp:curves (o / n i b p1 p2 a ch rr lst)
  (setq n (fix (+ 0.5 (vlax-curve-getEndParam o))) i 0)
  (repeat n
    (setq b (vla-GetBulge o i))
    (if (> (abs b) 1e-9)
      (progn
        (setq p1 (vlax-curve-getPointAtParam o i)
              p2 (vlax-curve-getPointAtParam o (1+ i))
              a  (* 4.0 (atan (abs b)))
              ch (distance p1 p2)
              rr (/ ch (* 2.0 (sin (/ a 2.0)))))
        (setq lst (cons (list (vlax-curve-getDistAtParam o i)
                              (vlax-curve-getDistAtParam o (1+ i))
                              rr a (if (> b 0) 1 -1) p1 p2)
                        lst))))
    (setq i (1+ i)))
  (reverse lst))

;;----------------------------------------------------------------------------
;;  Centre line input
;;----------------------------------------------------------------------------
(defun rp:get-centreline (/ prev e sel typ)
  (cond
    (*rp:presetcl* (setq e *rp:presetcl*))
    ((= (rp:val "mode") "0")
     (setvar "PLINETYPE" 2)
     (setvar "PLINEWID" 0.0)
     (setq prev (entlast))
     (princ "\nDraw the road centre line (Arc option allowed, Enter to finish):")
     (setvar "CMDECHO" 1)
     (command "_.PLINE")
     (while (> (getvar "CMDACTIVE") 0) (command pause))
     (setvar "CMDECHO" 0)
     (setq e (entlast))
     (if (equal e prev) (setq e nil)))
    (T
     (while
       (and (setq sel (entsel "\nSelect road centre line (Line / 2D Polyline / Arc / Civil 3D alignment): "))
            (not (wcmatch (cdr (assoc 0 (entget (car sel)))) "LINE,ARC,LWPOLYLINE,AECC_ALIGNMENT")))
       (princ "\n  Not supported - pick a Line, Arc, 2D (LW) Polyline or Civil 3D alignment."))
     (if sel
       (progn
         (setq e (car sel) typ (cdr (assoc 0 (entget e))))
         (cond
           ((= typ "AECC_ALIGNMENT")
            (setq e (rp:c3d-align e) typ "LWPOLYLINE")
            (if (and e *rp:c3dsta*)
              (progn
                (rp:set "chst" (rtos *rp:c3dsta* 2 3))
                (princ (strcat "\n  Start chainage set from the alignment: " (rtos *rp:c3dsta* 2 3))))))
           ((rp:on "keep")
            (setq e (vlax-vla-object->ename (vla-Copy (vlax-ename->vla-object e))))
            (princ "\n  The original line is kept - the road is built on a copy.")))
         (if (and e (/= typ "LWPOLYLINE"))
           (progn
             (setvar "PEDITACCEPT" 1)
             (command "_.PEDIT" e "")
             (setq e (entlast))))))))
  (if (and e
           (= (cdr (assoc 0 (entget e))) "LWPOLYLINE")
           (> (vlax-curve-getDistAtParam e (vlax-curve-getEndParam e)) 1e-6))
    e
    (progn (princ "\nNo valid centre line - nothing created.") nil)))

;;----------------------------------------------------------------------------
;;  Road surface hatch
;;----------------------------------------------------------------------------
(defun rp:surface (cl e1 e2 elev / o1 o2 tmp h bnd pat r)
  (if (and (= (length e1) 1) (= (length e2) 1))
    (progn
      (setq o1  (car e1)
            o2  (car e2)
            pat (strcase (vl-string-trim " " (rp:val "hpat"))))
      (if (vlax-curve-isClosed cl)
        (progn
          (if (< (vla-get-Area o1) (vla-get-Area o2)) (setq tmp o1 o1 o2 o2 tmp))
          (setq h (rp:newhatch pat T elev))
          (vla-put-Layer h "ROAD-SURFACE")
          (setq r (vl-catch-all-apply
                    (function
                      (lambda ()
                        (vla-AppendOuterLoop h (rp:objarr (list o1)))
                        (vla-AppendInnerLoop h (rp:objarr (list o2)))))
                    nil)))
        (progn
          (setq bnd (rp:mkpl (rp:bnd-verts o1 o2) "ROAD-SURFACE" elev T)
                h   (rp:newhatch pat nil elev))
          (vla-put-Layer h "ROAD-SURFACE")
          (setq r (vl-catch-all-apply 'vla-AppendOuterLoop (list h (rp:objarr (list bnd)))))))
      (cond
        ((vl-catch-all-error-p r)
         (vla-Delete h)
         (setq h nil)
         (princ "\nWarning: road surface hatch could not be created."))
        (T
         (if (/= (vla-get-PatternName h) "SOLID")
           (vl-catch-all-apply 'vla-put-PatternScale (list h (rp:num "hscl"))))
         (vla-Evaluate h)
         (vl-catch-all-apply 'vla-put-EntityTransparency (list h "50"))))
      (if bnd (vla-Delete bnd))
      h)
    (progn
      (princ "\nWarning: surface hatch skipped (edge offset split into several pieces).")
      nil)))

;;----------------------------------------------------------------------------
;;  Bands, cones and kerbs along a road
;;----------------------------------------------------------------------------
;; Solid band between side offsets o1 and o2 (+ left), chunked every 50 m.
;; lines = T also draws the two long boundary lines (black)
(defun rp:band (cl a b o1 o2 lay elev fac lines / s0 s1 n i d pa pb bnd h)
  (setq s0 a)
  (while (< s0 (- b 1e-6))
    (setq s1 (min b (+ s0 (* 50.0 fac)))
          n  (max 1 (fix (+ 0.999999 (/ (- s1 s0) fac))))
          i  0 pa nil pb nil)
    (repeat (1+ n)
      (setq d  (+ s0 (* (- s1 s0) (/ (float i) n)))
            pa (cons (rp:offpt cl d o1) pa)
            pb (cons (rp:offpt cl d o2) pb)
            i  (1+ i)))
    (setq bnd (rp:poly (append (reverse pa) pb) lay elev)
          h   (rp:newhatch "SOLID" nil elev))
    (vla-put-Layer h lay)
    (if (not (vl-catch-all-error-p (vl-catch-all-apply 'vla-AppendOuterLoop (list h (rp:objarr (list bnd))))))
      (progn
        (vla-Evaluate h)
        (setq *rp:hatches* (cons h *rp:hatches*))
        (if (= lay "ROAD-SHOULDER")                 ; v3.6 : pieces remembered so tie-ins can cut them
          (rp:ldata-add cl "ROADPRO_SHLD" (list (vla-get-Handle h) s0 s1 o1 o2 nil))))
      (vla-Delete h))
    (vla-Delete bnd)
    (setq s0 s1))
  (if lines
    (foreach o (list o1 o2)
      (setq i 0 pa nil n (max 1 (fix (+ 0.999999 (/ (- b a) fac)))))
      (repeat (1+ n)
        (setq pa (cons (list (rp:offpt cl (+ a (* (- b a) (/ (float i) n))) o) 0.0) pa) i (1+ i)))
      (rp:mkpl (reverse pa) "ROAD-BARRIER-OUTLINE" elev nil)))
  (- b a))

;; Traffic cone symbol (plan) : orange disc, white band, black outline
(defun rp:cone (c dia elev / o i)
  (setq o (vla-AddCircle *rp:spc* (rp:p3 c elev) (* 0.5 dia))
        i (vla-AddCircle *rp:spc* (rp:p3 c elev) (* 0.3 dia)))
  (vla-put-Layer o "ROAD-BARRIER-OUTLINE")
  (vla-put-Layer i "ROAD-CONE-BAND")
  (rp:solidfill o i "ROAD-CONE" elev)
  (rp:solidfill i nil "ROAD-CONE-BAND" elev)
  (vla-put-Layer (vla-AddCircle *rp:spc* (rp:p3 c elev) (* 0.12 dia)) "ROAD-BARRIER-OUTLINE"))

;; Cones along the road at side offset off, every sp. Returns the count
(defun rp:cones (cl len off sp dia elev / d n)
  (setq d (* 0.5 sp) n 0)
  (while (<= d len)
    (rp:cone (rp:offpt cl d off) dia elev)
    (setq n (1+ n) d (+ d sp)))
  n)

;;----------------------------------------------------------------------------
;;  Barricades : alternating red / white units between side offsets d1 and d2
;;----------------------------------------------------------------------------
;; One run of edge treatment between side offsets d1 (inner) and d2 (outer).
;; typ "0" barricades / "1" traffic cones / "2" kerb stone.
;; Returns (red white cones kerb-length)
(defun rp:edge-run (cl len d1 d2 typ blen fac elev / r)
  (cond
    ((= typ "1")
     (list 0 0 (rp:cones cl len (* 0.5 (+ d1 d2)) blen (abs (- d2 d1)) elev) 0.0))
    ((= typ "2")
     (setq *rp:unitfill* "ROAD-KERB"
           r (rp:barrier cl len d1 d2 blen (min blen (* 0.25 fac)) elev)
           *rp:unitfill* nil)
     (list 0 0 0 len))
    (T
     (setq r (rp:barrier cl len d1 d2 blen (min blen (* 0.25 fac)) elev))
     (list (car r) (cadr r) 0 0.0))))

;; Does the road have an edge treatment on side sg ?
(defun rp:edge-on (data sg)
  (or (/= (rp:xv (if (> sg 0) "BL" "BR") data) "0,0")
      (= (rp:xv (if (> sg 0) "EL" "ER") data) "1")))

(defun rp:etype (data) (if (= (rp:xv "ETYPE" data) "") "0" (rp:xv "ETYPE" data)))

(defun rp:barrier (cl len d1 d2 seg step elev / d de n i dd pa pb cnt nred nwht)
  (setq d 0.0 cnt 0 nred 0 nwht 0)
  (while (< d (- len 1e-6))
    (setq de (+ d seg))
    (if (> de (- len (* 0.25 seg))) (setq de len))      ; no tiny slivers at the end
    (setq n  (max 1 (fix (+ 0.999999 (/ (- de d) step))))
          pa nil pb nil i 0)
    (repeat (1+ n)
      (setq dd (+ d (* (- de d) (/ (float i) n)))
            pa (cons (rp:offpt cl dd d1) pa)
            pb (cons (rp:offpt cl dd d2) pb)
            i  (1+ i)))
    (rp:solidfill (rp:poly (append (reverse pa) pb) "ROAD-BARRIER-OUTLINE" elev)
                  nil
                  (cond (*rp:unitfill* *rp:unitfill*)
                        ((= 0 (rem cnt 2)) "ROAD-BARRIER-RED")
                        (T "ROAD-BARRIER-WHITE"))
                  elev)
    (if (= 0 (rem cnt 2)) (setq nred (1+ nred)) (setq nwht (1+ nwht)))
    (setq cnt (1+ cnt) d de))
  (list nred nwht))

;;----------------------------------------------------------------------------
;;  Signs
;;----------------------------------------------------------------------------
;; Speed limit : red ring, white centre, black number
(defun rp:sign-speed (c sz spd elev / o i)
  (setq o (vla-AddCircle *rp:spc* (rp:p3 c elev) (* 0.5 sz))
        i (vla-AddCircle *rp:spc* (rp:p3 c elev) (* 0.39 sz)))
  (vla-put-Layer o "ROAD-SIGN")
  (vla-put-Layer i "ROAD-SIGN-RED")
  (rp:solidfill o i "ROAD-SIGN-RED" elev)
  (rp:solidfill i nil "ROAD-SIGN-WHITE" elev)
  (rp:text spd c (* 0.32 sz) "ROAD-SIGN" elev))

;; Curve warning : red triangle with bend arrow (dir -1 = bend left, +1 = right)
(defun rp:pt+ (p v k) (list (+ (car p) (* k (car v))) (+ (cadr p) (* k (cadr v)))))

;; Triangle sign body : black outline, red border, white centre (inv = point down)
(defun rp:tri-sign (c sz elev inv / tri o i)
  (setq tri (if inv
              '((0.0 -0.57735) (0.5 0.288675) (-0.5 0.288675))
              '((0.0 0.57735) (-0.5 -0.288675) (0.5 -0.288675)))
        o   (rp:poly (rp:xf tri c 0.0 sz) "ROAD-SIGN" elev)
        i   (rp:poly (rp:xf tri c 0.0 (* 0.62 sz)) "ROAD-SIGN-RED" elev))
  (rp:solidfill o i "ROAD-SIGN-RED" elev)
  ;; warning triangles : yellow background (HDS Fig 19.1.2.1); give way : white
  (rp:solidfill i nil (if inv "ROAD-SIGN-WHITE" "ROAD-SIGN-YELLOW") elev))

;; Bend ahead : triangle with bend arrow (dir -1 = bend left, +1 = bend right)
(defun rp:sign-warn (c sz dir elev)
  (rp:tri-sign c sz elev nil)
  (rp:mkwpl
    (list (list (rp:xf1 '(0.0 -0.13) c sz) (* 0.035 sz) (* 0.035 sz))
          (list (rp:xf1 '(0.0 0.0) c sz)   (* 0.035 sz) (* 0.035 sz))
          (list (rp:xf1 (list (* dir 0.05) 0.05) c sz) (* 0.10 sz) 0.0)
          (list (rp:xf1 (list (* dir 0.11) 0.11) c sz) 0.0 0.0))
    "ROAD-SIGN" elev))

;; Road works ahead : triangle with "!" and a ROAD WORKS supplementary plate
(defun rp:icon-works (c sz elev / d)
  (rp:tri-sign c sz elev nil)
  (rp:solidfill (rp:poly (rp:xf '((-0.03 -0.03) (0.03 -0.03) (0.045 0.2) (-0.045 0.2)) c 0.0 sz)
                         "ROAD-SIGN" elev)
                nil "ROAD-SIGN" elev)
  (setq d (vla-AddCircle *rp:spc* (rp:p3 (rp:xf1 '(0.0 -0.1) c sz) elev) (* 0.04 sz)))
  (vla-put-Layer d "ROAD-SIGN")
  (rp:solidfill d nil "ROAD-SIGN" elev)
  (rp:solidfill (rp:poly (rp:xf '((-0.75 -0.72) (0.75 -0.72) (0.75 -0.4) (-0.75 -0.4)) c 0.0 sz)
                         "ROAD-SIGN" elev)
                nil "ROAD-SIGN-WHITE" elev)
  (rp:text "ROAD WORKS" (rp:xf1 '(0.0 -0.56) c sz) (* 0.14 sz) "ROAD-SIGN" elev))

(defun rp:ngon (n r a0 / i lst)
  (setq i 0)
  (repeat n
    (setq lst (cons (list (* r (cos (+ a0 (/ (* 2.0 pi i) n))))
                          (* r (sin (+ a0 (/ (* 2.0 pi i) n)))))
                    lst)
          i   (1+ i)))
  (reverse lst))

;; STOP : red octagon, white border, white STOP text
(defun rp:icon-stop (c sz elev / b)
  (rp:solidfill (rp:poly (rp:xf (rp:ngon 8 0.5 (/ pi 8.0)) c 0.0 sz) "ROAD-SIGN" elev)
                nil "ROAD-SIGN-RED" elev)
  (setq b (rp:poly (rp:xf (rp:ngon 8 0.45 (/ pi 8.0)) c 0.0 sz) "ROAD-SIGN-WHITE" elev))
  (vla-put-ConstantWidth b (* 0.025 sz))
  (rp:text "STOP" c (* 0.22 sz) "ROAD-SIGN-WHITE" elev))

;; GIVE WAY : inverted triangle
(defun rp:icon-giveway (c sz elev) (rp:tri-sign c sz elev T))

;; NO ENTRY : red disc with white bar
(defun rp:icon-noentry (c sz elev / o)
  (setq o (vla-AddCircle *rp:spc* (rp:p3 c elev) (* 0.5 sz)))
  (vla-put-Layer o "ROAD-SIGN")
  (rp:solidfill o nil "ROAD-SIGN-RED" elev)
  (rp:solidfill (rp:poly (rp:xf '((-0.34 -0.08) (0.34 -0.08) (0.34 0.08) (-0.34 0.08)) c 0.0 sz)
                         "ROAD-SIGN-WHITE" elev)
                nil "ROAD-SIGN-WHITE" elev))

;; KEEP RIGHT : blue disc with white arrow pointing down-right
(defun rp:icon-keepright (c sz elev / o)
  (setq o (vla-AddCircle *rp:spc* (rp:p3 c elev) (* 0.5 sz)))
  (vla-put-Layer o "ROAD-SIGN")
  (rp:solidfill o nil "ROAD-SIGN-BLUE" elev)
  (rp:solidfill (rp:poly (rp:xf '((-0.3 -0.06) (0.1 -0.06) (0.1 -0.16) (0.32 0.0)
                                  (0.1 0.16) (0.1 0.06) (-0.3 0.06))
                                c (* -0.25 pi) sz)
                         "ROAD-SIGN-WHITE" elev)
                nil "ROAD-SIGN-WHITE" elev))

(defun rp:draw-icon (typ c sz arg elev)
  (cond
    ((= typ "speed")     (rp:sign-speed c sz arg elev))
    ((= typ "warn")      (rp:sign-warn c sz (atof arg) elev))
    ((= typ "works")     (rp:icon-works c sz elev))
    ((= typ "stop")      (rp:icon-stop c sz elev))
    ((= typ "giveway")   (rp:icon-giveway c sz elev))
    ((= typ "noentry")   (rp:icon-noentry c sz elev))
    ((= typ "keepright") (rp:icon-keepright c sz elev))
    ((= typ "closed")    (rp:sign-closed c sz elev))))

;; Chevron board : white board with red chevron, pointing into the bend
(defun rp:chevron (c ang sz elev / k tmp)
  ;; permanent W37-1A : yellow board, black chevron ; road works 404/405 : black board, yellow chevron
  (setq k   (* 0.6 sz)
        tmp (= (rp:val "sset") "1"))
  (rp:solidfill (rp:poly (rp:xf '((-0.35 -0.45) (0.35 -0.45) (0.35 0.45) (-0.35 0.45)) c ang k)
                         "ROAD-SIGN" elev)
                nil (if tmp "ROAD-SIGN" "ROAD-SIGN-YELLOW") elev)
  (rp:solidfill (rp:poly (rp:xf '((-0.25 0.35) (0.0 0.35) (0.25 0.0) (0.0 -0.35) (-0.25 -0.35) (0.0 0.0))
                                c ang k)
                         "ROAD-SIGN" elev)
                nil (if tmp "ROAD-SIGN-YELLOW" "ROAD-SIGN") elev))

(defun rp:chevrons (cl c off sz fac elev / n k d f)
  (setq n (max 3 (1+ (fix (/ (- (cadr c) (car c)) (* 10.0 fac))))) k 0)
  (repeat n
    (setq d (+ (car c) (* (- (cadr c) (car c)) (/ (float k) (1- n))))
          f (rp:frame cl d))
    (rp:chevron (rp:loc f off 0.0)
                (+ (angle '(0.0 0.0) (caddr f)) (* (nth 4 c) 0.5 pi))
                sz elev)
    (setq k (1+ k)))
  n)

;; ROAD CLOSED : road works sign 406 (yellow diamond, black border and text)
;; for the temporary sign set, otherwise a white board with red border
(defun rp:sign-closed (c sz elev / o i)
  (if (= (rp:val "sset") "1")
    (progn
      (setq o (rp:poly (rp:xf '((0.0 -0.75) (0.75 0.0) (0.0 0.75) (-0.75 0.0)) c 0.0 sz) "ROAD-SIGN" elev))
      (vla-put-ConstantWidth o (* 0.03 sz))
      (rp:solidfill (rp:poly (rp:xf '((0.0 -0.75) (0.75 0.0) (0.0 0.75) (-0.75 0.0)) c 0.0 sz) "ROAD-SIGN" elev)
                    nil "ROAD-SIGN-YELLOW" elev)
      (rp:text "ROAD" (rp:xf1 '(0.0 0.1) c sz) (* 0.16 sz) "ROAD-SIGN" elev)
      (rp:text "CLOSED" (rp:xf1 '(0.0 -0.12) c sz) (* 0.16 sz) "ROAD-SIGN" elev))
    (rp:sign-closed-board c sz elev)))

(defun rp:sign-closed-board (c sz elev / o i)
  (setq o (rp:poly (rp:xf '((-1.1 -0.4) (1.1 -0.4) (1.1 0.4) (-1.1 0.4)) c 0.0 sz) "ROAD-SIGN" elev)
        i (rp:poly (rp:xf '((-1.0 -0.3) (1.0 -0.3) (1.0 0.3) (-1.0 0.3)) c 0.0 sz) "ROAD-SIGN-RED" elev))
  (rp:solidfill o i "ROAD-SIGN-RED" elev)
  (rp:solidfill i nil "ROAD-SIGN-WHITE" elev)
  (rp:text "ROAD CLOSED" c (* 0.17 sz) "ROAD-SIGN" elev))

;;----------------------------------------------------------------------------
;;  Oman HDS 2017 Section 19 values by speed limit (GCC Manual based)
;;  (triangle side, circular dia, STOP side, GIVE WAY height, warning distance)
;;  Tables 19.1.3.3, 19.1.3.4, 19.1.3.6. STOP / GIVE WAY sizes are not given
;;  for 100 and 120 km/h; the 80 km/h values are used there.
;;----------------------------------------------------------------------------
(defun rp:hds-row (spd)
  (cond ((<= spd 50) '(600 600 750 750 50))
        ((<= spd 60) '(750 750 900 750 75))
        ((<= spd 80) '(900 750 1200 900 150))
        ((<= spd 100) '(1200 900 1200 900 200))
        (T '(1500 1200 1200 900 300))))

;; plate size text for a sign type
(defun rp:plate (typ spd / r)
  (setq r (rp:hds-row spd))
  (cond ((member typ '("works" "warn")) (strcat "Triangle " (itoa (nth 0 r))))
        ((member typ '("speed" "keepright" "noentry")) (strcat "Circle " (itoa (nth 1 r))))
        ((= typ "stop") (strcat "Octagon " (itoa (nth 2 r))))
        ((= typ "giveway") (strcat "Triangle " (itoa (nth 3 r))))
        (T "-")))

;; lane line patterns (mark, gap) in m - Figure 19.2.1.1 table 1
(defun rp:l1 (spd) (cond ((<= spd 50) '(2.0 6.0)) ((<= spd 80) '(3.0 9.0)) (T '(4.0 12.0))))
(defun rp:l2 (spd) (cond ((<= spd 50) '(6.0 2.0)) ((<= spd 80) '(9.0 3.0)) (T '(12.0 4.0))))

;;----------------------------------------------------------------------------
;;  Signage engine : post + plate facing traffic + leader + symbol + ID tag
;;----------------------------------------------------------------------------
(defun rp:sign-post (post n ic sz fac id plate elev / pc)
  (setq pc (vla-AddCircle *rp:spc* (rp:p3 post elev) (* 0.15 fac)))
  (vla-put-Layer pc "ROAD-SIGN")
  (rp:solidfill pc nil "ROAD-SIGN" elev)
  (rp:mkwpl (list (list (rp:pt+ post n (* -0.45 fac)) (* 0.12 fac) (* 0.12 fac))
                  (list (rp:pt+ post n (* 0.45 fac)) 0.0 0.0))
            "ROAD-SIGN" elev)
  (if (> (distance post ic) (* 0.6 sz))
    (rp:line post (rp:towards ic post (* 0.55 sz)) "ROAD-SIGN" elev))
  (rp:text id (list (car ic) (- (cadr ic) (if plate (* 0.95 sz) (* 0.72 sz))))
           (* 0.22 sz) "ROAD-SIGN" elev))

;; r = (dist side facing type arg description)   side R / L / M(edian) / X(across)
(defun rp:draw-sign (cl r id sz fac elev offR offL xL len / d side f n post ic in)
  (setq d (car r) side (nth 1 r) f (rp:frame cl d) n (cadr f))
  (cond
    ((= side "R")
     (setq post (rp:loc f (- offR) 0.0)
           ic   (rp:loc f (- (+ offR (* 0.6 fac) (* 0.7 sz))) 0.0)))
    ((= side "L")
     (setq post (rp:loc f offL 0.0)
           ic   (rp:loc f (+ offL (* 0.6 fac) (* 0.7 sz) xL) 0.0)))
    ((= side "M")
     (setq post (car f)
           ic   (rp:loc f 0.0 (* (if (= (nth 2 r) "F") -1.0 1.0) (+ fac (* 0.8 sz))))))
    (T
     (setq in   (if (> d (* 0.5 len)) -1.0 1.0)
           post (car f)
           ic   (rp:loc f 0.0 (* -1.0 in (+ fac (* 0.5 sz)))))))
  (if (= side "X")
    (rp:text id (list (car ic) (- (cadr ic) (* 0.6 sz))) (* 0.22 sz) "ROAD-SIGN" elev)
    (progn
      (rp:draw-icon (nth 3 r) ic sz (nth 4 r) elev)
      (rp:sign-post post n ic sz fac id (= (nth 3 r) "works") elev)))
  post)

(defun rp:dpos (len dr d) (if (= dr 1) (min len d) (max 0.0 (- len d))))

;; Plans and draws all signs, returns the sign schedule :
;; list of (ID description chainage side facing E N type arg)
(defun rp:signs (cl len curves fac sz elev offR offL xL ends endf closed st
                 / two sp wd spd d0 reqs sd fc lr jt jd i id post sched)
  (setq two (rp:on "twoway")
        sp  (* fac (rp:num "ssp"))
        wd  (* fac (if (rp:on "sauto") (nth 4 (rp:hds-row (rp:num "speed"))) (rp:num "warnd")))
        spd (rtos (rp:num "speed") 2 0)
        d0  (min (* 5.0 fac) (* 0.25 len)))
  ;; entry signs : forward traffic at the start, reverse traffic at the end
  (foreach dr (if two '(1 -1) '(1))
    (setq sd (if (= dr 1) "R" "L") fc (if (= dr 1) "F" "B"))
    (if (rp:on "srw")
      (setq reqs (cons (list (rp:dpos len dr d0) sd fc "works" "" "Road works ahead") reqs)))
    (if (rp:on "sspeed")
      (setq reqs (cons (list (rp:dpos len dr (+ d0 (if (rp:on "srw") sp 0.0))) sd fc "speed" spd
                             (strcat "Speed limit " spd " km/h"))
                       reqs)))
    (if (and (rp:on "bc") (rp:on "skr"))
      (setq reqs (cons (list (rp:dpos len dr 0.0) "M" fc "keepright" "" "Keep right") reqs))))
  ;; bend ahead, before every bend of 10 deg or more
  (if (rp:on "swarn")
    (foreach c curves
      (if (>= (nth 3 c) (/ pi 18.0))
        (progn
          (setq lr (> (nth 4 c) 0))
          (setq reqs (cons (list (max 0.0 (- (car c) wd)) "R" "F" "warn" (if lr "-1" "1")
                                 (strcat "Bend ahead - " (if lr "left" "right")))
                           reqs))
          (if two
            (setq reqs (cons (list (min len (+ (cadr c) wd)) "L" "B" "warn" (if lr "1" "-1")
                                   (strcat "Bend ahead - " (if lr "right" "left")))
                             reqs)))))))
  ;; tie-in control, no entry, road closed boards
  (if (not closed)
    (progn
      (setq jt (cond ((= (rp:val "jctl") "0") "stop") ((= (rp:val "jctl") "1") "giveway"))
            jd (if (= jt "stop") "STOP" "Give way"))
      (if (and jt (member endf '("0" "3")))
        (setq reqs (cons (list (max 0.0 (- len (* 3.0 fac))) "R" "F" jt "" jd) reqs)))
      (if (and jt two (member ends '("0" "3")))
        (setq reqs (cons (list (min len (* 3.0 fac)) "L" "B" jt "" jd) reqs)))
      (if (and (not two) (/= endf "1"))
        (setq reqs (cons (list (max 0.0 (- len (* 3.0 fac))) "L" "B" "noentry" "" "No entry") reqs)))
      (if (= ends "1") (setq reqs (cons (list 0.0 "X" "B" "closed" "" "Road closed board") reqs)))
      (if (= endf "1") (setq reqs (cons (list len "X" "F" "closed" "" "Road closed board") reqs)))))
  ;; number in chainage order and draw
  (setq reqs (vl-sort reqs '(lambda (a b) (< (car a) (car b))))
        i    0)
  (foreach r reqs
    (setq i     (1+ i)
          id    (strcat "SG-" (rp:z2 i))
          post  (rp:draw-sign cl r id sz fac elev offR offL xL len)
          sched (cons (list id (nth 5 r) (rp:chfmt (+ st (/ (car r) fac)))
                            (cdr (assoc (nth 1 r) '(("R" . "Right") ("L" . "Left")
                                                    ("M" . "Median") ("X" . "Across road"))))
                            (if (= (nth 2 r) "F") "Forward (CH +)" "Reverse (CH -)")
                            (rtos (/ (car post) fac) 2 3) (rtos (/ (cadr post) fac) 2 3)
                            (nth 3 r) (nth 4 r)
                            (rp:plate (nth 3 r) (rp:num "speed")))
                      sched)))
  (reverse sched))

;; Lane direction arrow marking (5 m long), pointing in direction ang
;; Straight arrow S3 (HDS Fig 19.2.1.5) : 5.0 m long up to 60 km/h, 7.5 m above
(defun rp:arrow (c ang k elev / l h)
  (setq l (* 0.5 (if (and *rp:arrl* (> *rp:arrl* 0.0)) *rp:arrl* 5.0))
        h (- l 2.05))
  (rp:solidfill
    (rp:poly (rp:xf (list (list (- l) -0.075) (list h -0.075) (list h -0.375) (list l 0.0)
                          (list h 0.375) (list h 0.075) (list (- l) 0.075))
                    c ang k)
             "ROAD-MARKING" elev)
    nil "ROAD-MARKING-FILL" elev))

;; Delineator posts on the outside of a curve (HDS Fig 19.1.2.7) : spacing S by
;; radius inside the curve, then 2S, 3S, 6S (max 100 m) on the tangents
(defun rp:deli-s (r)
  (cond ((>= r 500.0) 50.0) ((>= r 300.0) (+ 30.0 (* 20.0 (/ (- r 300.0) 200.0))))
        ((>= r 200.0) (+ 20.0 (* 10.0 (/ (- r 200.0) 100.0))))
        ((>= r 100.0) (+ 15.0 (* 5.0 (/ (- r 100.0) 100.0))))
        ((>= r 75.0) (+ 12.0 (* 3.0 (/ (- r 75.0) 25.0))))
        ((>= r 50.0) (+ 10.0 (* 2.0 (/ (- r 50.0) 25.0))))
        ((>= r 25.0) (+ 7.0 (* 3.0 (/ (- r 25.0) 25.0))))
        (T 7.0)))

(defun rp:deli-post (p fac elev / o)
  (setq o (rp:poly (list (list (- (car p) (* 0.075 fac)) (- (cadr p) (* 0.075 fac)))
                         (list (+ (car p) (* 0.075 fac)) (- (cadr p) (* 0.075 fac)))
                         (list (+ (car p) (* 0.075 fac)) (+ (cadr p) (* 0.075 fac)))
                         (list (- (car p) (* 0.075 fac)) (+ (cadr p) (* 0.075 fac))))
                   "ROAD-BARRIER-OUTLINE" elev))
  (rp:solidfill o nil "ROAD-DELINEATOR" elev)
  (vla-put-Layer (vla-AddCircle *rp:spc* (rp:p3 p elev) (* 0.035 fac)) "ROAD-SIGN-RED"))

(defun rp:delineators (cl len curves offL offR fac elev / n c s sp d out lst)
  (setq n 0)
  (foreach c curves
    (if (>= (nth 3 c) (/ pi 36.0))
      (progn
        (setq s   (* fac (rp:deli-s (/ (nth 2 c) fac)))
              out (if (> (nth 4 c) 0) (- offR) offL)
              lst nil d (car c))
        (while (<= d (+ (cadr c) 1e-6)) (setq lst (cons d lst) d (+ d s)))
        (foreach k (list (* 2.0 s) (+ (* 2.0 s) (min (* 3.0 s) (* 100.0 fac)))
                         (+ (* 2.0 s) (min (* 3.0 s) (* 100.0 fac)) (min (* 6.0 s) (* 100.0 fac))))
          (setq lst (cons (- (car c) k) (cons (+ (cadr c) k) lst))))
        (foreach d lst
          (if (and (>= d 0.0) (<= d len))
            (progn (rp:deli-post (rp:offpt cl d out) fac elev) (setq n (1+ n))))))))
  n)

;; Arrows in both lanes on every straight of 12 m or more (one set per 60 m)
(defun rp:lane-arrows (cl strs hw fac two elev / n s ln k i d f a)
  (setq n 0)
  (foreach s strs
    (setq ln (- (cadr s) (car s)))
    (if (>= ln (* 12.0 fac))
      (progn
        (setq k (max 1 (fix (/ ln (* 60.0 fac)))) i 1)
        (repeat k
          (setq d (+ (car s) (* ln (/ (float i) (1+ k))))
                f (rp:frame cl d)
                a (angle '(0.0 0.0) (caddr f)))
          (if *rp:lanes*
            (foreach lnx *rp:lanes*
              (rp:arrow (rp:loc f (car lnx) 0.0) (if (and two (cadr lnx)) (+ a pi) a) fac elev)
              (setq n (1+ n)))
            (progn
              (rp:arrow (rp:loc f (* -0.5 hw) 0.0) a fac elev)
              (rp:arrow (rp:loc f (* 0.5 hw) 0.0) (if two (+ a pi) a) fac elev)
              (setq n (+ n 2))))
          (setq i (1+ i))))))
  n)

;; Left-aligned text
(defun rp:ltext (str pt h lay / tx)
  (setq tx (vla-AddText *rp:spc* str (rp:p3 pt 0.0) h))
  (vla-put-Alignment tx acAlignmentMiddleLeft)
  (vla-put-TextAlignmentPoint tx (rp:p3 pt 0.0))
  (vla-put-Layer tx lay)
  tx)

;; Sign legend with real symbols, for the report
(defun rp:legend (pt sched th / lz x y seen pc)
  (setq lz (* 3.0 th) x (car pt) y (cadr pt))
  (rp:ltext "SIGN LEGEND" (list x y) (* 1.3 th) "ROAD-REPORT")
  (setq y (- y (* 1.6 lz)))
  (foreach r sched
    (if (not (member (nth 1 r) seen))
      (progn
        (setq seen (cons (nth 1 r) seen))
        (rp:draw-icon (nth 7 r) (list (+ x lz) y) (if (= (nth 7 r) "closed") (* 0.6 lz) lz) (nth 8 r) 0.0)
        (rp:ltext (nth 1 r) (list (+ x (* 2.4 lz)) y) th "ROAD-REPORT")
        (setq y (- y (if (= (nth 7 r) "works") (* 2.0 lz) (* 1.5 lz)))))))
  ;; post, chevron board, lane arrow, ID tag
  (setq pc (vla-AddCircle *rp:spc* (rp:p3 (list (+ x lz) y) 0.0) (* 0.06 lz)))
  (vla-put-Layer pc "ROAD-SIGN")
  (rp:solidfill pc nil "ROAD-SIGN" 0.0)
  (rp:mkwpl (list (list (list (+ x lz) (- y (* 0.25 lz))) (* 0.05 lz) (* 0.05 lz))
                  (list (list (+ x lz) (+ y (* 0.25 lz))) 0.0 0.0))
            "ROAD-SIGN" 0.0)
  (rp:ltext "Sign post with plate (plate faces the traffic)" (list (+ x (* 2.4 lz)) y) th "ROAD-REPORT")
  (setq y (- y (* 1.3 lz)))
  (rp:chevron (list (+ x lz) y) 0.0 lz 0.0)
  (rp:ltext "Chevron board (points into the bend)" (list (+ x (* 2.4 lz)) y) th "ROAD-REPORT")
  (setq y (- y (* 1.3 lz)))
  (rp:arrow (list (+ x lz) y) 0.0 (/ lz 4.0) 0.0)
  (rp:ltext "Lane direction arrow (road marking)" (list (+ x (* 2.4 lz)) y) th "ROAD-REPORT")
  (setq y (- y (* 1.3 lz)))
  (rp:text "SG-01" (list (+ x lz) y) (* 0.5 th) "ROAD-SIGN" 0.0)
  (rp:ltext "Sign ID - see SIGN SCHEDULE" (list (+ x (* 2.4 lz)) y) th "ROAD-REPORT"))

;;----------------------------------------------------------------------------
;;  Road ends : "0" tie-in line / "1" road closed / "2" none
;;  returns (red-units white-units road-closed-signs)
;;----------------------------------------------------------------------------
(defun rp:road-end (cl d atend mode hw blen bwid th fac sz elev ch / f in p s s2 cnt nr nw ln mt ip)
  (setq f (rp:frame cl d) in (if atend -1.0 1.0) p (car f) nr 0 nw 0)
  (cond
    ((= mode "0")
     (setq ln (vla-AddLine *rp:spc* (rp:p3 (rp:loc f (- (+ hw fac)) 0.0) elev)
                                    (rp:p3 (rp:loc f (+ hw fac) 0.0) elev)))
     (vla-put-Layer ln "ROAD-TIEIN")
     (vla-put-LinetypeScale ln (/ fac (getvar "LTSCALE")))
     (foreach s (list (- hw) 0.0 hw)
       (vla-put-Layer (vla-AddCircle *rp:spc* (rp:p3 (rp:loc f s 0.0) elev) (* 0.3 fac)) "ROAD-TIEIN"))
     (setq ip (rp:loc f 0.0 (* -1.0 in (+ fac (* 3.0 th))))
           mt (vla-AddMText *rp:spc* (rp:p3 ip elev) (* 30.0 th)
                (strcat "TIE-IN WITH EXISTING ROAD\\PCH " (rp:chfmt ch)
                        "\\PE " (rtos (/ (car p) fac) 2 3) "   N " (rtos (/ (cadr p) fac) 2 3))))
     (vla-put-Height mt th)
     (vla-put-AttachmentPoint mt acAttachmentPointMiddleCenter)
     (vla-put-InsertionPoint mt (rp:p3 ip elev))
     (vla-put-Layer mt "ROAD-TIEIN")
     (list 0 0 0))
    ((= mode "1")
     (setq s (- hw) cnt 0)
     (while (< s (- hw 1e-6))
       (setq s2 (min hw (+ s blen)))
       (if (> s2 (- hw (* 0.25 blen))) (setq s2 hw))
       (rp:solidfill
         (rp:poly (list (rp:loc f s 0.0) (rp:loc f s2 0.0)
                        (rp:loc f s2 (* in bwid)) (rp:loc f s (* in bwid)))
                  "ROAD-BARRIER-OUTLINE" elev)
         nil (if (= 0 (rem cnt 2)) "ROAD-BARRIER-RED" "ROAD-BARRIER-WHITE") elev)
       (if (= 0 (rem cnt 2)) (setq nr (1+ nr)) (setq nw (1+ nw)))
       (setq cnt (1+ cnt) s s2))
     (rp:sign-closed (rp:loc f 0.0 (* -1.0 in (+ fac (* 0.5 sz)))) sz elev)
     (list nr nw 1))
    (T (list 0 0 0))))

;;----------------------------------------------------------------------------
;;  Chainage
;;----------------------------------------------------------------------------
(defun rp:chfmt (v / km m s p)
  (setq v  (/ (fix (+ (* v 1000.0) (if (< v 0) -0.5 0.5))) 1000.0)
        km (fix (/ v 1000.0))
        m  (abs (- v (* km 1000.0)))
        s  (if (equal m (fix (+ m 0.5)) 0.0005) (itoa (fix (+ m 0.5))) (rtos m 2 3)))
  (while (< (if (setq p (vl-string-search "." s)) p (strlen s)) 3)
    (setq s (strcat "0" s)))
  (strcat (if (and (< v 0) (= km 0)) "-" "") (itoa km) "+" s))

(defun rp:chmark (cl d v hw lofs th elev / a b ip ang flip ln tx)
  (setq a    (rp:offpt cl d (- hw))
        b    (rp:offpt cl d hw)
        ip   (rp:offpt cl d lofs)
        ang  (angle a b)
        flip (and (> ang (* 0.5 pi)) (<= ang (* 1.5 pi))))
  (setq ln (vla-AddLine *rp:spc* (rp:p3 a elev) (rp:p3 b elev)))
  (vla-put-Layer ln "ROAD-CHAINAGE")
  (setq tx (vla-AddText *rp:spc* (strcat "CH " (rp:chfmt v)) (rp:p3 ip elev) th))
  (vla-put-Layer tx "ROAD-CHAINAGE")
  (vla-put-Alignment tx (if flip acAlignmentMiddleRight acAlignmentMiddleLeft))
  (vla-put-TextAlignmentPoint tx (rp:p3 ip elev))
  (vla-put-Rotation tx (if flip (+ ang pi) ang)))

(defun rp:chainage (cl len fac hw lofs elev closed / iv st th k d dl n)
  (setq iv   (* fac (rp:num "chint"))
        st   (rp:num "chst")
        th   (* fac (rp:num "txth"))
        lofs (+ lofs (* 0.5 th))
        dl   (list 0.0)
        k    (fix (/ (* st fac) iv))
        d    (- (* (1+ k) iv) (* st fac)))
  (if (< d (* 0.001 iv)) (setq d (+ d iv)))
  (while (< d (- len (* 2.0 th)))
    (setq dl (cons d dl) d (+ d iv)))
  (if (not closed) (setq dl (cons len dl)))
  (setq n 0)
  (foreach x (reverse dl)
    (rp:chmark cl x (+ st (/ x fac)) hw lofs th elev)
    (setq n (1+ n)))
  n)

;;----------------------------------------------------------------------------
;;  Radius on plan : radius line + arrow + R value, centre mark, TC / CT ticks
;;  with chainage and a curve data label for every bend
;;----------------------------------------------------------------------------
(defun rp:towards (a b dist / l)
  (setq l (distance a b))
  (if (< l 1e-12)
    a
    (list (+ (car a)  (* dist (/ (- (car b) (car a)) l)))
          (+ (cadr a) (* dist (/ (- (cadr b) (cadr a)) l))))))

(defun rp:line (a b lay elev / ln)
  (setq ln (vla-AddLine *rp:spc* (rp:p3 a elev) (rp:p3 b elev)))
  (vla-put-Layer ln lay)
  ln)

;; Text beside the road at distance d, offset off (+ left / - right), reading outward
(defun rp:sidetext (cl d str off th lay elev / a ip ang flip tx)
  (setq a    (rp:offpt cl d 0.0)
        ip   (rp:offpt cl d off)
        ang  (angle a ip)
        flip (and (> ang (* 0.5 pi)) (<= ang (* 1.5 pi))))
  (setq tx (vla-AddText *rp:spc* str (rp:p3 ip elev) th))
  (vla-put-Layer tx lay)
  (vla-put-Alignment tx (if flip acAlignmentMiddleRight acAlignmentMiddleLeft))
  (vla-put-TextAlignmentPoint tx (rp:p3 ip elev))
  (vla-put-Rotation tx (if flip (+ ang pi) ang)))

;; bl / br : barricades on left / right,  chon : chainage labels on (left side)
(defun rp:curve-labels (cl curves hw fac th st elev bl br chon bgap bwid atcl
                        / n c dir rr ri dm ctr edge sp ang rot mid ah tx mt lo ix)
  (setq n 0)
  (foreach c curves
    (setq n (1+ n))                                        ; same numbers as report C1, C2...
    (if (> (nth 3 c) 0.0175)                               ; ignore bends under 1 deg
      (progn
        (setq dir  (nth 4 c)                               ; +1 left turn / -1 right turn
              rr   (nth 2 c)                               ; radius at centre line
              ri   (- rr hw)                               ; radius at inner edge
              dm   (* 0.5 (+ (car c) (cadr c)))            ; middle of the curve
              ctr  (rp:offpt cl dm (* dir rr))             ; curve centre point
              edge (rp:offpt cl dm (* dir hw)))            ; inner edge, mid curve
        (if atcl (setq edge (rp:offpt cl dm 0.0)))         ; radius shown to the centre line
        (if (> ri 0.0)
          (progn
            ;; radius line : full from centre, or a short leader for big radii
            (setq sp (if (<= ri (+ (* 50.0 fac) (rp:cin dir))) ctr (rp:towards edge ctr (+ (* 12.0 th) (rp:cin dir))))
                  ah (rp:towards edge sp (* 0.7 th)))
            (rp:mkwpl (list (list sp 0.0 0.0) (list ah (* 0.35 th) 0.0) (list edge 0.0 0.0))
                      "ROAD-CURVE" elev)
            ;; centre mark
            (if (equal sp ctr 1e-9)
              (progn
                (rp:line (polar ctr 0.0 (* 0.6 th)) (polar ctr pi (* 0.6 th)) "ROAD-CURVE" elev)
                (rp:line (polar ctr (* 0.5 pi) (* 0.6 th)) (polar ctr (* 1.5 pi) (* 0.6 th))
                         "ROAD-CURVE" elev)))
            ;; R value along the radius line (always readable)
            (setq ang (angle sp edge)
                  rot (if (and (> ang (* 0.5 pi)) (<= ang (* 1.5 pi))) (+ ang pi) ang)
                  mid (polar (rp:towards sp edge (* 0.5 (distance sp edge))) (+ rot (* 0.5 pi)) (* 0.7 th))
                  tx  (rp:text (strcat "R=" (rtos (/ (if atcl rr ri) fac) 2 2) (if atcl " CL" ""))
                               mid th "ROAD-CURVE" elev))
            (vla-put-Rotation tx rot)
            ;; curve data label, beyond the start of the radius line
            (setq ix (polar sp (angle edge sp) (* 3.5 th))
                  mt (vla-AddMText *rp:spc* (rp:p3 ix elev) 0.0
                       (strcat "C" (itoa n)
                               "\\PR inner = " (rtos (/ ri fac) 2 3) " m"
                               "\\PR CL = "    (rtos (/ rr fac) 2 3) " m"
                               "\\PR outer = " (rtos (/ (+ rr hw) fac) 2 3) " m"
                               "\\PL (CL) = "  (rtos (/ (- (cadr c) (car c)) fac) 2 3) " m"
                               "\\PA = " (rtos (/ (* 2.0 hw (- (cadr c) (car c))) fac fac) 2 2) " m\\U+00B2"
                               "\\P\\U+0394 = " (vl-string-subst "\\U+00B0" "%%d" (rp:dms (nth 3 c) T)))))
            (vla-put-Height mt (* 0.8 th))
            (vla-put-AttachmentPoint mt acAttachmentPointMiddleCenter)
            (vla-put-InsertionPoint mt (rp:p3 ix elev))
            (vla-put-Layer mt "ROAD-CURVE")))
        ;; TC / CT ticks across the road + labels on the inner side
        (setq lo (* dir (+ hw
                           (if (if (> dir 0) bl br) (+ bgap bwid) 0.0)
                           (rp:cin dir)
                           (* 0.3 fac) (* 0.5 th)
                           (if (and chon (> dir 0)) (* 11.0 th) 0.0))))
        (foreach tp (list (list (car c) "TC") (list (cadr c) "CT"))
          (rp:line (rp:offpt cl (car tp) (- hw)) (rp:offpt cl (car tp) hw) "ROAD-CURVE" elev)
          (rp:sidetext cl (car tp)
                       (strcat (cadr tp) (itoa n) "  " (rp:chfmt (+ st (/ (car tp) fac))))
                       lo (* 0.8 th) "ROAD-CURVE" elev)))))
  n)

;;----------------------------------------------------------------------------
;;  Straight sections : list of (dist-start dist-end direction-angle P1 P2)
;;----------------------------------------------------------------------------
(defun rp:straights (o / n i p1 p2 lst)
  (setq n (fix (+ 0.5 (vlax-curve-getEndParam o))) i 0)
  (repeat n
    (if (< (abs (vla-GetBulge o i)) 1e-9)
      (progn
        (setq p1 (vlax-curve-getPointAtParam o i)
              p2 (vlax-curve-getPointAtParam o (1+ i)))
        (if (> (distance p1 p2) 1e-6)
          (setq lst (cons (list (vlax-curve-getDistAtParam o i)
                                (vlax-curve-getDistAtParam o (1+ i))
                                (angle p1 p2) p1 p2)
                          lst)))))
    (setq i (1+ i)))
  (reverse lst))

;; Whole-circle bearing (from North, clockwise) of a drawing angle
(defun rp:brg (ang) (rem (+ (- (* 0.5 pi) ang) (* 4.0 pi)) (* 2.0 pi)))

;; Plan labels for straights, on the right side beyond barricades and signs
;; ob = clear distance from the centre line to start drawing
(defun rp:straight-labels (cl strs hw fac th st elev ob / n s d1 d2 od ot ang rot ip mt)
  (setq n  0
        od (- (+ ob (* 0.8 th)))          ; extent bar
        ot (- (+ ob (* 4.2 th))))         ; label centre
  (foreach s strs
    (setq n  (1+ n)
          d1 (car s)
          d2 (cadr s))
    ;; extent bar with end ticks
    (rp:line (rp:offpt cl d1 od) (rp:offpt cl d2 od) "ROAD-SECTION" elev)
    (rp:line (rp:offpt cl d1 (+ od (* 0.6 th))) (rp:offpt cl d1 (- od (* 0.6 th))) "ROAD-SECTION" elev)
    (rp:line (rp:offpt cl d2 (+ od (* 0.6 th))) (rp:offpt cl d2 (- od (* 0.6 th))) "ROAD-SECTION" elev)
    ;; label, parallel to the road and always readable
    (setq ang (nth 2 s)
          rot (if (and (> ang (* 0.5 pi)) (<= ang (* 1.5 pi))) (+ ang pi) ang)
          ip  (rp:offpt cl (* 0.5 (+ d1 d2)) ot)
          mt  (vla-AddMText *rp:spc* (rp:p3 ip elev) 0.0
                (strcat "S" (itoa n) "  STRAIGHT"
                        "\\PL = " (rtos (/ (- d2 d1) fac) 2 3) " m    A = "
                        (rtos (/ (* 2.0 hw (- d2 d1)) fac fac) 2 2) " m\\U+00B2"
                        "\\PCH " (rp:chfmt (+ st (/ d1 fac))) " - " (rp:chfmt (+ st (/ d2 fac)))
                        "\\PBRG " (vl-string-subst "\\U+00B0" "%%d" (rp:dms (rp:brg ang) T)))))
    (vla-put-Height mt (* 0.8 th))
    (vla-put-AttachmentPoint mt acAttachmentPointMiddleCenter)
    (vla-put-InsertionPoint mt (rp:p3 ip elev))
    (vla-put-Rotation mt rot)
    (vla-put-Layer mt "ROAD-SECTION"))
  n)

;;----------------------------------------------------------------------------
;;  Road data stored on the centre line (XDATA) - used by ROADREPORT
;;----------------------------------------------------------------------------
(defun rp:xput (e alst)
  (regapp "ROADPRO")
  (entmod (append (entget e)
                  (list (list -3 (cons "ROADPRO"
                                       (mapcar '(lambda (p) (cons 1000 (strcat (car p) "=" (cdr p))))
                                               alst)))))))

(defun rp:xget (e / x p)
  (setq x (cdr (assoc "ROADPRO" (cdr (assoc -3 (entget e '("ROADPRO")))))))
  (mapcar '(lambda (g / s)
             (setq s (cdr g) p (vl-string-search "=" s))
             (if p (cons (substr s 1 p) (substr s (+ p 2))) (cons s "")))
          x))

(defun rp:xv (k data / v) (if (setq v (cdr (assoc k data))) v ""))

(defun rp:pair (r) (if r (strcat (itoa (car r)) "," (itoa (cadr r))) "0,0"))

(defun rp:pairget (s / p)
  (if (and s (setq p (vl-string-search "," s)))
    (list (atoi (substr s 1 p)) (atoi (substr s (+ p 2))))
    (list 0 0)))

;;----------------------------------------------------------------------------
;;  Report
;;----------------------------------------------------------------------------
(defun rp:today () (menucmd "M=$(edtime,$(getvar,date),DD-MON-YYYY)"))

(defun rp:pad (s n) (while (< (strlen s) n) (setq s (strcat s " "))) s)

(defun rp:fm (v) (strcat (rtos v 2 3) " m"))

(defun rp:z2 (n) (if (< n 10) (strcat "0" (itoa n)) (itoa n)))

(defun rp:dms (a tbl / ts d m s)
  (setq ts (fix (+ (* (/ a pi) 648000.0) 0.5))
        d  (/ ts 3600)
        m  (/ (rem ts 3600) 60)
        s  (rem ts 60))
  (if tbl
    (strcat (itoa d) "%%d" (rp:z2 m) "'" (rp:z2 s) "\"")
    (strcat (itoa d) "d " (rp:z2 m) "m " (rp:z2 s) "s")))

(defun rp:brow (lbl pr)
  (if (> (+ (car pr) (cadr pr)) 0)
    (list lbl (strcat (itoa (car pr)) " red + " (itoa (cadr pr)) " white = "
                      (itoa (+ (car pr) (cadr pr))) " units"))))

(defun rp:endtxt (mode p fac)
  (strcat (cond ((= mode "0") "Tie-in") ((= mode "1") "Road closed")
                ((= mode "2") "Open end") ((= mode "3") "Junction") (T "Closed loop"))
          "  E " (rtos (/ (car p) fac) 2 3) "  N " (rtos (/ (cadr p) fac) 2 3)))

(defun rp:join (lst sep)
  (if lst (apply 'strcat (cons (car lst) (mapcar '(lambda (x) (strcat sep x)) (cdr lst)))) ""))

(defun rp:csv (f lst)
  (write-line
    (rp:join (mapcar '(lambda (s) (strcat "\"" (vl-string-translate "\"" "'" s) "\"")) lst) ",")
    f))

(defun rp:write-csv (path title rows crows srows secs signs wsto tsto jsto / f)
  (if (setq f (open path "w"))
    (progn
      (rp:csv f (list title))
      (foreach r rows
        (if (= (car r) "#")
          (progn (rp:csv f '("")) (rp:csv f (list (cadr r))))
          (rp:csv f r)))
      (rp:csv f '(""))
      (rp:csv f '("CURVE DATA"))
      (rp:csv f '("No" "Turn" "TC Chainage" "CT Chainage" "Radius CL (m)" "Arc Length CL (m)"
                  "Deflection" "TC Easting" "TC Northing" "CT Easting" "CT Northing"))
      (if crows (foreach r crows (rp:csv f r)) (rp:csv f '("-" "No curves")))
      (rp:csv f '(""))
      (rp:csv f '("ROAD SECTIONS"))
      (rp:csv f '("Section" "Type" "From Chainage" "To Chainage" "Length CL (m)"
                  "Left Edge (m)" "Right Edge (m)" "Area (m2)" "Bearing / Radius"))
      (foreach r secs (rp:csv f r))
      (rp:csv f '(""))
      (rp:csv f '("SIGN SCHEDULE"))
      (rp:csv f '("Sign ID" "Sign" "Chainage" "Side" "Facing traffic" "Post Easting" "Post Northing" "Plate size (mm)"))
      (foreach r signs (rp:csv f r))
      (if wsto
        (progn
          (rp:csv f '(""))
          (rp:csv f '("LANE WIDENING SETTING-OUT (new road edge)"))
          (rp:csv f '("Widening" "Point" "Chainage" "Offset from CL (m, + left)" "Easting" "Northing"))
          (foreach r wsto (rp:csv f r))))
      (if tsto
        (progn
          (rp:csv f '(""))
          (rp:csv f '("ROAD TAPER SETTING-OUT (new road edge)"))
          (rp:csv f '("Taper" "Point" "Chainage" "Offset from CL (m, + left)" "Easting" "Northing"))
          (foreach r tsto (rp:csv f r))))
      (if jsto
        (progn
          (rp:csv f '(""))
          (rp:csv f '("JUNCTION SETTING-OUT (kerb returns)"))
          (rp:csv f '("Junction" "Point" "Chainage" "Easting" "Northing"))
          (foreach r jsto (rp:csv f r))))
      (rp:csv f '(""))
      (rp:csv f '("SETTING-OUT DATA"))
      (rp:csv f '("Point" "Chainage" "CL Easting" "CL Northing" "Left Edge Easting"
                  "Left Edge Northing" "Right Edge Easting" "Right Edge Northing"))
      (foreach r srows (rp:csv f r))
      (close f)
      path)
    (progn (princ (strcat "\nCould not write " path " - is it open in Excel?")) nil)))

(defun rp:mktable (pt title hdr rows cw th / nc nr tb r c)
  (setq nc (length cw)
        nr (+ 2 (length rows))
        tb (vla-AddTable *rp:spc* (vlax-3d-point pt) nr nc (* 1.8 th) (car cw)))
  (vla-put-RegenerateTableSuppressed tb :vlax-true)
  (vla-put-Layer tb "ROAD-REPORT")
  (vl-catch-all-apply 'vla-put-HorzCellMargin (list tb (* 0.4 th)))
  (vl-catch-all-apply 'vla-put-VertCellMargin (list tb (* 0.3 th)))
  (vla-SetTextHeight tb acTitleRow (* 1.3 th))
  (vla-SetTextHeight tb acHeaderRow th)
  (vla-SetTextHeight tb acDataRow th)
  (setq c 0)
  (foreach wd cw (vla-SetColumnWidth tb c wd) (setq c (1+ c)))
  (vla-SetText tb 0 0 title)
  (setq c 0)
  (foreach h hdr (vla-SetText tb 1 c h) (setq c (1+ c)))
  (setq r 2)
  (foreach row rows
    (if (= (car row) "#")
      (progn
        (vla-MergeCells tb r r 0 (1- nc))
        (vla-SetText tb r 0 (cadr row))
        (vla-SetCellAlignment tb r 0 acMiddleLeft))
      (progn
        (setq c 0)
        (foreach s row
          (if (< c nc)
            (progn
              (vla-SetText tb r c s)
              (vla-SetCellAlignment tb r c (if (= c 0) acMiddleLeft acMiddleCenter))))
          (setq c (1+ c)))))
    (setq r (1+ r)))
  (vla-put-RegenerateTableSuppressed tb :vlax-false)
  tb)

(defun rp:tables (pt name rows ctab srows sect schd sched wsto tsto jsto th / x t1)
  (setq t1 (rp:mktable pt (strcat "ROAD REPORT - " name) '("DESCRIPTION" "VALUE")
                       rows (list (* 28.0 th) (* 28.0 th)) th))
  (if sched
    (rp:legend (list (car pt) (- (cadr pt) (vla-get-Height t1) (* 5.0 th))) sched th))
  (setq x (+ (car pt) (* 59.0 th)))
  (rp:mktable (list x (cadr pt) 0.0) "CURVE DATA"
              '("No" "TURN" "TC CH" "CT CH" "RADIUS (m)" "ARC (m)" "DEFLECTION")
              (if ctab ctab (list (list "-" "No curves" "" "" "" "" "")))
              (mapcar '(lambda (k) (* k th)) '(4.0 6.0 10.0 10.0 9.0 8.0 11.0)) th)
  (setq x (+ x (* 61.0 th)))
  (rp:mktable (list x (cadr pt) 0.0) "SETTING-OUT DATA"
              '("POINT" "CHAINAGE" "CL E" "CL N" "LEFT E" "LEFT N" "RIGHT E" "RIGHT N")
              srows (mapcar '(lambda (k) (* k th)) '(9.0 10.0 12.0 12.0 12.0 12.0 12.0 12.0)) th)
  (setq x (+ x (* 93.0 th)))
  (rp:mktable (list x (cadr pt) 0.0) "ROAD SECTIONS"
              '("SEC" "TYPE" "FROM CH" "TO CH" "LENGTH (m)" "LEFT (m)" "RIGHT (m)" "AREA (m2)" "BEARING / RADIUS")
              sect (mapcar '(lambda (k) (* k th)) '(5.0 8.0 10.0 10.0 9.0 9.0 9.0 10.0 15.0)) th)
  (setq x (+ x (* 87.0 th)))
  (rp:mktable (list x (cadr pt) 0.0) "SIGN SCHEDULE"
              '("ID" "SIGN" "CHAINAGE" "SIDE" "FACING TRAFFIC" "POST E" "POST N" "PLATE (mm)")
              schd (mapcar '(lambda (k) (* k th)) '(6.0 18.0 10.0 9.0 13.0 12.0 12.0 12.0)) th)
  (setq x (+ x (* 12.0 th)))   ; plate column added to the sign schedule
  (if wsto
    (progn
      (setq x (+ x (* 82.0 th)))
      (rp:mktable (list x (cadr pt) 0.0) "LANE WIDENING SETTING-OUT"
                  '("WIDENING" "POINT" "CHAINAGE" "OFFSET (m)" "EASTING" "NORTHING")
                  wsto (mapcar '(lambda (k) (* k th)) '(9.0 7.0 10.0 10.0 12.0 12.0)) th)))
  (if tsto
    (progn
      (setq x (+ x (if wsto (* 62.0 th) (* 82.0 th))))
      (rp:mktable (list x (cadr pt) 0.0) "ROAD TAPER SETTING-OUT"
                  '("TAPER" "POINT" "CHAINAGE" "OFFSET (m)" "EASTING" "NORTHING")
                  tsto (mapcar '(lambda (k) (* k th)) '(9.0 7.0 10.0 10.0 12.0 12.0)) th)))
  (if jsto
    (progn
      (setq x (+ x (if (or wsto tsto) (* 62.0 th) (* 82.0 th))))
      (rp:mktable (list x (cadr pt) 0.0) "JUNCTION SETTING-OUT"
                  '("JUNCTION" "POINT" "CHAINAGE" "EASTING" "NORTHING")
                  jsto (mapcar '(lambda (k) (* k th)) '(9.0 9.0 14.0 12.0 12.0)) th))))

;; Main report : full = T  -> command line + CSV + tables in drawing
;;               full = nil -> command line only
(defun rp:report-make (e full / data fac w hw obj len closed st iv curves tsum rin rc
                         bl br bc be nr nw ns rows ctab ccsv srows pts mp i k d p pl pr
                         name path pt th lbl strs sl cl secs sect secc a q
                         sched sgrows cnt schd wid wrows wsto wtot tr ttot jr mq mrows)
  (setq data (rp:xget e)
        fac  (atof (rp:xv "FAC" data)))
  (if (<= fac 0.0) (setq fac 1.0))
  (setq w        (* fac (atof (rp:xv "W" data)))
        hw       (* 0.5 w)
        obj      (vlax-ename->vla-object e)
        len      (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
        *rp:len* len
        closed   (vlax-curve-isClosed obj)
        st       (atof (rp:xv "CHST" data))
        iv       (* fac (atof (rp:xv "CHINT" data)))
        curves   (rp:curves obj)
        name     (rp:xv "NAME" data)
        tsum     0.0)
  (foreach c curves (setq tsum (+ tsum (* (nth 4 c) (nth 3 c)))))
  (setq strs (rp:straights obj) sl 0.0 cl 0.0)
  (foreach s strs (setq sl (+ sl (- (cadr s) (car s)))))
  (foreach c curves (setq cl (+ cl (- (cadr c) (car c)))))
  (setq rin (atof (rp:xv "RIN" data))
        rc  (cond ((<= rin 0.0) 0.0)
                  ((= (rp:xv "RREF" data) "0") (+ rin (/ hw fac)))
                  (T rin))
        bl  (rp:pairget (rp:xv "BL" data))
        br  (rp:pairget (rp:xv "BR" data))
        bc  (rp:pairget (rp:xv "BC" data))
        be  (rp:pairget (rp:xv "BE" data))
        nr  (+ (car bl) (car br) (car bc) (car be))
        nw  (+ (cadr bl) (cadr br) (cadr bc) (cadr be))
        ns  (+ (atoi (rp:xv "NSPD" data)) (atoi (rp:xv "NWRN" data))
               (atoi (rp:xv "NCHV" data)) (atoi (rp:xv "NCLS" data))))
  ;; ---- signs : from the sign schedule (older roads : stored counts) ----
  (setq sched (vlax-ldata-get obj "ROADPRO_SIGNS"))
  (if sched
    (progn
      (foreach r sched
        (if (setq a (assoc (nth 1 r) cnt))
          (setq cnt (subst (cons (car a) (1+ (cdr a))) a cnt))
          (setq cnt (cons (cons (nth 1 r) 1) cnt))))
      (setq sgrows (mapcar '(lambda (x) (list (car x) (itoa (cdr x)))) (reverse cnt))))
    (setq sgrows (list (list (strcat "Speed limit signs (" (rp:xv "SPEED" data) " km/h)") (rp:xv "NSPD" data))
                       (list "Curve warning signs" (rp:xv "NWRN" data))
                       (list "ROAD CLOSED signs" (rp:xv "NCLS" data)))))
  ;; ---- lane widening ----
  (setq wid (vlax-ldata-get obj "ROADPRO_WIDEN") wtot 0.0)
  (if wid
    (progn
      (setq wrows (list '("#" "LANE WIDENING")))
      (foreach r wid
        (setq wtot  (+ wtot (atof (nth 9 r)))
              wrows (append wrows
                            (list (list (strcat (car r) " - " (cadr r) " side")
                                        (strcat "+" (caddr r) " m,  CH " (nth 3 r) " - " (nth 4 r)))
                                  (list (strcat "   " (car r) " taper in / out")
                                        (strcat (nth 5 r) " / " (nth 6 r) " m,  " (nth 7 r)))
                                  (list (strcat "   " (car r) " match points") (nth 8 r))
                                  (list (strcat "   " (car r) " area") (strcat (nth 9 r) " m2")))))
        (foreach q (nth 10 r) (setq wsto (cons q wsto))))
      (setq wsto  (reverse wsto)
            wrows (append wrows
                          (list (list "Widening area total" (strcat (rtos wtot 2 2) " m2"))
                                (list "Total paved area (road + widening)"
                                      (strcat (rtos (+ (/ (* w len) fac fac) wtot) 2 2) " m2")))))))
  ;; ---- junctions ----
  (setq jr (rp:junc-report obj))
  ;; ---- road markings (paint quantities) ----
  (setq mq (vlax-ldata-get obj "ROADPRO_MKQTY"))
  (if mq
    (setq mrows (list '("#" "ROAD MARKINGS")
                      (list "Yellow edge lines L4 (both sides)" (strcat (rtos (/ (car mq) fac) 2 1) " m"))
                      (list (strcat "White centre line(s) 120 mm - "
                                    (cond ((= (rp:xv "CMARK" data) "1") "double continuous")
                                          ((= (rp:xv "CMARK" data) "2") "L2A continuous")
                                          (T "L1 / L2 / L2A by speed")))
                            (strcat (rtos (/ (cadr mq) fac) 2 1) " m"))
                      (list "SLOW words / lane arrows" (strcat (itoa (fix (caddr mq))) " / " (rp:xv "NARR" data)))
                      (list "Paint area (lines)"
                            (strcat (rtos (+ (* 0.12 (/ (car mq) fac)) (* 0.12 (/ (cadr mq) fac))) 2 2) " m2")))))
  ;; ---- road tapers ----
  (setq tr   (rp:taper-report obj fac hw st iv len)
        ttot (if tr (list (list "Total paved area (road + widening + tapers)"
                                (strcat (rtos (+ (/ (* w len) fac fac) wtot (caddr tr)) 2 2) " m2")))))
  ;; ---- summary rows ----
  (setq rows
    (vl-remove nil
     (append
      (list
        '("#" "GENERAL")
        (list "Road name / ID" name)
        (list "Report date" (rp:today))
        (list "Road created" (rp:xv "DATE" data))
        (list "Drawing" (getvar "DWGNAME"))
        (list "Drawing units" (if (= fac 1.0) "Meters" "Millimeters"))
        '("#" "GEOMETRY")
        (list "Start chainage" (rp:chfmt st))
        (list "End chainage" (rp:chfmt (+ st (/ len fac))))
        (list "Centre line length" (rp:fm (/ len fac)))
        (list "Road width" (rp:fm (/ w fac)))
        (list "Left edge length" (rp:fm (/ (- len (* hw tsum)) fac)))
        (list "Right edge length" (rp:fm (/ (+ len (* hw tsum)) fac)))
        (list "Road surface area" (strcat (rtos (/ (* w len) fac fac) 2 2) " m2"))
        (list "Straight sections" (strcat (itoa (length strs)) "  (total " (rp:fm (/ sl fac)) ")"))
        (list "Curve sections" (strcat (itoa (length curves)) "  (total " (rp:fm (/ cl fac)) ")"))
        (list "Design turning radius"
              (if (> rc 0.0)
                (strcat "inner " (rtos (- rc (/ hw fac)) 2 2) " / CL " (rtos rc 2 2)
                        " / outer " (rtos (+ rc (/ hw fac)) 2 2) " m")
                (if (= (rp:xv "RMODE" data) "0") "Match existing (CL as drawn)" "none")))
        (list "Minimum CL radius"
              (if curves (rp:fm (/ (apply 'min (mapcar 'caddr curves)) fac)) "-"))
        '("#" "ROAD EDGE, SHOULDER AND CENTRE")
        (list "Edge treatment"
              (cond ((= (rp:xv "ETYPE" data) "1") "Traffic cones")
                    ((= (rp:xv "ETYPE" data) "2") "Kerb stone")
                    (T "Barricades (red / white)")))
        (list "Centre"
              (cond ((= (rp:xv "CTYPE" data) "1") "Barricades (red / white)")
                    ((= (rp:xv "CTYPE" data) "2") "Traffic cones")
                    ((= (rp:xv "CTYPE" data) "0")
                     (cond ((member (rp:xv "MED" data) '("1" "2")) "Median (see corridor)")
                           ((= (rp:xv "CMARK" data) "1") "Double continuous white line")
                           ((= (rp:xv "CMARK" data) "2") "Single continuous line L2A")
                           (T "Centre line L1 / L2 / L2A by speed")))
                    (T (if (/= (rp:xv "BC" data) "0,0") "Barricades (red / white)" "Lane line"))))
        (list "Paved shoulder" (strcat (rp:xv "BGAP" data) " m each side,  area "
                                       (rtos (* 2.0 (atof (rp:xv "BGAP" data)) (/ len fac)) 2 2) " m2"))
        (if (= (rp:xv "ETYPE" data) "1")
          (list "Traffic cones (left / right)" (strcat (rp:xv "EQL" data) " / " (rp:xv "EQR" data) " nos")))
        (if (= (rp:xv "ETYPE" data) "2")
          (list "Kerb stone (left / right)" (strcat (rp:xv "EQL" data) " / " (rp:xv "EQR" data) " m")))
        (if (= (rp:xv "CTYPE" data) "2")
          (list "Centre traffic cones" (strcat (rp:xv "EQC" data) " nos")))
        (list "Unit size (L x W)" (strcat (rp:xv "BLEN" data) " x " (rp:xv "BWID" data) " m"))
        (rp:brow "Left side" bl)
        (rp:brow "Right side" br)
        (rp:brow "Centre median" bc)
        (rp:brow "Road-end closures" be)
        (list "TOTAL barricades" (strcat (itoa nr) " red + " (itoa nw) " white = "
                                         (itoa (+ nr nw)) " units"))
        '("#" "SIGNS AND MARKINGS"))
      sgrows
      (list
        (list "TOTAL signs" (if sched (itoa (length sched)) (itoa ns)))
        (if (/= (rp:xv "NDELI" data) "") (list "Delineator posts on curves" (rp:xv "NDELI" data)))
        (list "Sign set" (if (= (rp:xv "SSET" data) "1") "Temporary (road works)" "Permanent"))
        (list "Signs and markings reference" "Oman HDS 2017 Sec.19 / GCC Manual - check QTCM in Qatar")
        (list "Chevron boards on bends" (if (= (rp:xv "NCHV" data) "") "0" (rp:xv "NCHV" data)))
        (list "Lane direction arrows" (if (= (rp:xv "NARR" data) "") "0" (rp:xv "NARR" data)))
        '("#" "ROAD ENDS")
        (list "Start" (rp:endtxt (rp:xv "ENDS" data) (rp:offpt obj 0.0 0.0) fac))
        (list "Finish" (rp:endtxt (rp:xv "ENDF" data) (rp:offpt obj len 0.0) fac))
        '("#" "CHAINAGE")
        (list "Interval" (rp:fm (/ iv fac)))
        (list "Chainage marks" (rp:xv "NCHM" data)))
      wrows (car tr) ttot (car jr) mrows (rp:corr-rows obj data) (rp:pave-rows obj data fac len w wtot tr))))
  ;; ---- command line ----
  (princ "\n")
  (princ "\n==================== ROAD PRO - REPORT ====================")
  (foreach r rows
    (if (= (car r) "#")
      (princ (strcat "\n  [" (cadr r) "]"))
      (princ (strcat "\n    " (rp:pad (car r) 30) ": " (cadr r)))))
  (princ "\n===========================================================")
  (if full
    (progn
      ;; ---- curve data ----
      (setq i 1)
      (foreach c curves
        (setq k (list (itoa i) (if (> (nth 4 c) 0) "Left" "Right")
                      (rp:chfmt (+ st (/ (car c) fac))) (rp:chfmt (+ st (/ (cadr c) fac)))
                      (rtos (/ (nth 2 c) fac) 2 3) (rtos (/ (- (cadr c) (car c)) fac) 2 3)))
        (setq ctab (cons (append k (list (rp:dms (nth 3 c) T))) ctab)
              ccsv (cons (append k (list (rp:dms (nth 3 c) nil)
                                         (rtos (/ (car (nth 5 c)) fac) 2 3)
                                         (rtos (/ (cadr (nth 5 c)) fac) 2 3)
                                         (rtos (/ (car (nth 6 c)) fac) 2 3)
                                         (rtos (/ (cadr (nth 6 c)) fac) 2 3)))
                         ccsv)
              i    (1+ i)))
      (setq ctab (reverse ctab) ccsv (reverse ccsv))
      ;; ---- setting-out points ----
      (setq pts (list (cons 0.0 "START")))
      (if (not closed) (setq pts (cons (cons len "END") pts)))
      (if (> iv 0.0)
        (progn
          (setq k (fix (/ (* st fac) iv))
                d (- (* (1+ k) iv) (* st fac)))
          (if (< d (* 0.001 iv)) (setq d (+ d iv)))
          (while (< d (- len (* 0.001 iv)))
            (setq pts (cons (cons d "CH") pts) d (+ d iv)))))
      (setq i 1)
      (foreach c curves
        (setq pts (cons (cons (car c) (strcat "TC" (itoa i)))
                        (cons (cons (cadr c) (strcat "CT" (itoa i))) pts))
              i   (1+ i)))
      (setq pts (vl-sort pts '(lambda (a b) (< (car a) (car b)))))
      (foreach q pts
        (if (and mp (< (- (car q) (caar mp)) (* 0.001 fac)))
          (setq mp (cons (cons (caar mp)
                               (cond ((= (cdar mp) "CH") (cdr q))
                                     ((= (cdr q) "CH") (cdar mp))
                                     (T (strcat (cdar mp) "/" (cdr q)))))
                         (cdr mp)))
          (setq mp (cons q mp))))
      (foreach q (reverse mp)
        (setq p  (rp:offpt obj (car q) 0.0)
              pl (rp:offpt obj (car q) hw)
              pr (rp:offpt obj (car q) (- hw))
              srows (cons (list (cdr q) (rp:chfmt (+ st (/ (car q) fac)))
                                (rtos (/ (car p) fac) 2 3)  (rtos (/ (cadr p) fac) 2 3)
                                (rtos (/ (car pl) fac) 2 3) (rtos (/ (cadr pl) fac) 2 3)
                                (rtos (/ (car pr) fac) 2 3) (rtos (/ (cadr pr) fac) 2 3))
                          srows)))
      (setq srows (reverse srows))
      ;; ---- road sections : straights and curves in road order ----
      (setq i 0)
      (foreach s strs
        (setq i (1+ i) secs (cons (list (car s) (strcat "S" (itoa i)) s) secs)))
      (setq i 0)
      (foreach c curves
        (setq i (1+ i) secs (cons (list (car c) (strcat "C" (itoa i)) c) secs)))
      (setq secs (vl-sort secs '(lambda (a b) (< (car a) (car b)))))
      (foreach q secs
        (setq a (caddr q)
              d (- (cadr a) (car a))
              k (list (cadr q)
                      (if (= (substr (cadr q) 1 1) "S")
                        "Straight"
                        (if (> (nth 4 a) 0) "Curve Left" "Curve Right"))
                      (rp:chfmt (+ st (/ (car a) fac)))
                      (rp:chfmt (+ st (/ (cadr a) fac)))
                      (rtos (/ d fac) 2 3)
                      (rtos (/ (if (= (substr (cadr q) 1 1) "S") d (- d (* (nth 4 a) hw (nth 3 a)))) fac) 2 3)
                      (rtos (/ (if (= (substr (cadr q) 1 1) "S") d (+ d (* (nth 4 a) hw (nth 3 a)))) fac) 2 3)
                      (rtos (/ (* w d) fac fac) 2 2)))
        (if (= (substr (cadr q) 1 1) "S")
          (setq sect (cons (append k (list (strcat "BRG " (rp:dms (rp:brg (nth 2 a)) T)))) sect)
                secc (cons (append k (list (strcat "BRG " (rp:dms (rp:brg (nth 2 a)) nil)))) secc))
          (setq sect (cons (append k (list (strcat "R " (rtos (/ (nth 2 a) fac) 2 3) " m (CL)"))) sect)
                secc (cons (append k (list (strcat "R " (rtos (/ (nth 2 a) fac) 2 3) " m (CL)"))) secc))))
      (setq sect (reverse sect) secc (reverse secc))
      ;; ---- sign schedule ----
      (setq schd (if sched
                   (mapcar '(lambda (r) (list (nth 0 r) (nth 1 r) (nth 2 r) (nth 3 r)
                                              (nth 4 r) (nth 5 r) (nth 6 r)
                                              (if (nth 9 r) (nth 9 r) "-")))
                           sched)
                   (list (list "-" "No sign schedule" "" "" "" "" "" ""))))
      ;; ---- Excel (CSV) ----
      (setq path (rp:write-csv
                   (strcat (getvar "DWGPREFIX")
                           (vl-string-translate "\\/:*?\"<>| " "__________" name)
                           "_RoadPro_Report.csv")
                   (strcat "ROAD PRO REPORT - " name) rows ccsv srows secc schd wsto (cadr tr) (cadr jr)))
      (if path (princ (strcat "\n  Excel report saved : " path)))
      ;; ---- tables in drawing ----
      (setq th (* 0.8 fac (rp:num "txth")))
      (if (setq pt (getpoint "\nPick top-left corner for report tables <Enter = skip>: "))
        (rp:tables pt name rows ctab srows sect schd sched wsto (cadr tr) (cadr jr) th))
      (if path
        (progn
          (initget "Yes No")
          (if (/= (getkword "\nOpen the Excel report now? [Yes/No] <Yes>: ") "No")
            (startapp "explorer" (strcat "\"" path "\"")))))))
  (princ))

;;----------------------------------------------------------------------------
;;  Main builder
;;----------------------------------------------------------------------------
(defun rp:run (/ fac w hw rad0 rc ri blen bwid bgap step cl obj len elev closed lt
                 
                 e1 e2 surf resL resR resC resE nch curves strs sz th st ends endf r
                 offR offL sched nChv nArr nCls et ct eqL eqR eqC sho plan mo chk mark0 k)
  (rp:space)
  (setq *rp:hatches* nil
        *rp:conc* (if (member (rp:val "ptype") '("1" "2")) T nil)
        fac  (if (= (rp:val "units") "1") 1000.0 1.0)
        plan (rp:lane-plan (rp:num "width"))
        w    (* fac (car plan))
        mo   (* fac (nth 5 plan))
        hw   (* 0.5 w)
        rad0 (* fac (rp:num "radius"))
        blen (* fac (rp:num "blen"))
        bwid (* fac (rp:num "bwid"))
        bgap (* fac (rp:num "bgap"))
        et   (rp:val "etype")
        ct   (rp:val "ctype")
        *rp:arrl* (if (<= (rp:num "speed") 60.0) (* 5.0 1.0) 7.5)
        rc   (cond ((= (rp:val "rmode") "0") 0.0)            ; match existing : keep the CL as drawn
                   ((<= rad0 0.0) 0.0)
                   ((= (rp:val "rref") "1") (+ rad0 hw))     ; radius given at inner edge
                   (T rad0))                                  ; radius given at centre line
        ri   (- rc hw))
  (cond
    ((and (> rc 0.0) (<= ri 0.0))
     (alert (strcat "Turning radius is too small for this road width.\n\n"
                    "Measured at the centre line it must be more than half\n"
                    "the road width (" (rtos (/ hw fac) 2 2) " m).")))
    ((car (setq chk (rp:corr-check (rp:num "width"))))
     (alert (strcat "Lanes, median, sidewalks ... settings are not valid:\n\n" (rp:join2 (car chk) "\n"))))
    (T
     (rp:world)
     (rp:linetypes)
     (rp:layers)
     (setq mark0 (entlast))
     (foreach m (cadr chk) (princ (strcat "\n  Corridor warning: " m)))
     (foreach m (nth 6 plan) (princ (strcat "\n  " m)))
     (if (and (setq cl (rp:get-centreline)) (rp:cl-ok cl rc fac hw))
       (progn
         ;; 1. turning radius at every bend : filleted in rp:cl-ok
         (setq obj      (vlax-ename->vla-object cl)
               elev     (vla-get-Elevation obj)
               closed   (vlax-curve-isClosed obj)
               len      (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
               *rp:len* len
               curves   (rp:curves obj))
         (vl-catch-all-apply 'vla-put-ConstantWidth (list obj 0.0))
         ;; 2. road edges
         (setq e1 (rp:offset obj hw)
               e2 (rp:offset obj (- hw)))
         (foreach o (append e1 e2) (rp:props o "ROAD-EDGE" "ByLayer" 1.0))
         ;; 3. centre line
         (setq lt (rp:cl-ltype))
         (rp:props obj "ROAD-CL" lt (/ fac (getvar "LTSCALE")))
         ;; 4. road surface
         (if (rp:on "hatch") (setq surf (rp:surface obj e1 e2 elev)))
         (if surf (rp:surf-color surf))
         (vlax-ldata-put obj "ROADPRO_SURF" (if surf (list (vla-get-Handle surf))))   ; v3.6 : cut by roundabouts
         ;; 4b. paved shoulders between the carriageway edge and the edge treatment
         (setq sho nil)
         (if (> bgap 0.0)
           (foreach sg '(1.0 -1.0)
             (setq sho (cons (rp:band obj 0.0 len (* sg hw) (* sg (+ hw bgap)) "ROAD-SHOULDER" elev fac nil) sho))))
         ;; 5. edge treatment : barricades / cones / kerb stone, and the centre
         (if (and (> rc 0.0) (or (rp:on "bl") (rp:on "br")) (<= ri (+ bgap bwid)))
           (princ "\nWarning: the edge treatment on the inside of bends is tighter than the radius - increase the radius or reduce the width / shoulder."))
         (setq step (min blen (* 0.5 fac)) eqL "0" eqR "0" eqC "0")
         (foreach sg (vl-remove nil (list (if (rp:on "bl") 1.0) (if (rp:on "br") -1.0)))
           (cond
             ((= et "1")
              (setq r (itoa (rp:cones obj len (* sg (+ hw bgap (* 0.5 bwid))) blen bwid elev))))
             ((= et "2")
              (setq *rp:unitfill* "ROAD-KERB")
              (rp:barrier obj len (* sg (+ hw bgap)) (* sg (+ hw bgap bwid)) blen step elev)
              (setq *rp:unitfill* nil
                    r (rtos (/ len fac) 2 1)))
             (T
              (setq r (rp:barrier obj len (* sg (+ hw bgap)) (* sg (+ hw bgap bwid)) blen step elev))
              (if (> sg 0) (setq resL r) (setq resR r))
              (setq r (itoa (+ (car r) (cadr r))))))
           (if (> sg 0) (setq eqL r) (setq eqR r)))
         (cond
           ((= ct "1")
            (setq resC (rp:barrier obj len (+ mo (* -0.5 bwid)) (+ mo (* 0.5 bwid)) blen step elev)
                  eqC  (itoa (+ (car resC) (cadr resC)))))
           ((= ct "2")
            (setq eqC (itoa (rp:cones obj len mo blen bwid elev)))))
         ;; 6. chainage
         (setq th (* fac (rp:num "txth"))
               st (rp:num "chst"))
         (if (rp:on "ch")
           (setq nch (rp:chainage obj len fac hw
                                  (+ hw (if (rp:on "bl") (+ bgap bwid) 0.0) (rp:corr-extra 1.0 fac bgap bwid) (* 0.3 fac))
                                  elev closed)))
         ;; 6b. radius, TC / CT and curve data on plan
         (setq *rp:cinx* (list (rp:corr-extra 1.0 fac bgap bwid) (rp:corr-extra -1.0 fac bgap bwid)))
         (if (rp:on "rlab")
           (rp:curve-labels obj curves hw fac th st elev (rp:on "bl") (rp:on "br")
                            (rp:on "ch") bgap bwid (= (rp:val "rref") "0")))
         (setq *rp:cinx* nil)
         ;; 6c. straight sections on plan (right side, beyond barricades and signs)
         (setq sz   (* fac (rp:num "signsz"))
               offR (+ hw (if (rp:on "br") (+ bgap bwid) 0.0) (* 0.5 fac))
               offL (+ hw (if (rp:on "bl") (+ bgap bwid) 0.0) (* 0.5 fac))
               strs (rp:straights obj))
         (if (rp:on "slab")
           (rp:straight-labels obj strs hw fac th st elev (+ offR (* 0.6 fac) (* 1.5 sz) (rp:corr-extra -1.0 fac bgap bwid))))
         ;; 7. road ends
         (setq resE (list 0 0)
               nCls 0
               ends (if closed "-" (rp:val "endst"))
               endf (if closed "-" (rp:val "endfn")))
         (if (not closed)
           (foreach en (list (list 0.0 nil ends) (list len T endf))
             (setq r    (rp:road-end obj (car en) (cadr en) (caddr en) hw blen bwid th fac sz
                                     elev (+ st (/ (car en) fac)))
                   resE (list (+ (car resE) (car r)) (+ (cadr resE) (cadr r)))
                   nCls (+ nCls (caddr r)))))
         ;; 8. chevron boards on the outside of every bend of 10 deg or more
         (setq nChv 0
               offR (+ hw bgap (if (rp:on "br") bwid 0.0) (* 0.5 fac))
               offL (+ hw bgap (if (rp:on "bl") bwid 0.0) (* 0.5 fac)))
         ;; 8b. delineator posts : 0.30 m beyond the paved shoulder / edge treatment
         (setq *rp:ndeli* 0)
         (if (rp:on "deli")
           (setq *rp:ndeli* (rp:delineators obj len curves (- offL (* 0.2 fac)) (- offR (* 0.2 fac)) fac elev)))
         (if (rp:on "schev")
           (foreach c curves
             (if (>= (nth 3 c) (/ pi 18.0))
               (setq nChv (+ nChv (rp:chevrons obj c
                                               (if (> (nth 4 c) 0)
                                                 (- (+ offR (* 0.35 sz)))
                                                 (+ offL (* 0.35 sz)))
                                               sz fac elev))))))
         ;; 9. signs : post, plate, leader, symbol, ID tag (traffic keeps right)
         (setq sched (rp:signs obj len curves fac sz elev offR offL
                               (if (rp:on "ch") (* 10.0 th) 0.0) ends endf closed st))
         ;; 10. lane direction arrows
         (setq *rp:lanes* nil k 1)
         (if (> (nth 1 plan) 0)
           (progn
             (repeat (nth 2 plan)
               (setq *rp:lanes* (cons (list (- mo (* 0.5 fac (nth 4 plan)) (* fac (nth 3 plan) (- k 0.5))) nil) *rp:lanes*) k (1+ k)))
             (setq k 1)
             (repeat (nth 1 plan)
               (setq *rp:lanes* (cons (list (+ mo (* 0.5 fac (nth 4 plan)) (* fac (nth 3 plan) (- k 0.5))) T) *rp:lanes*) k (1+ k)))))
         (setq nArr (if (rp:on "sarr") (rp:lane-arrows obj strs hw fac (rp:on "twoway") elev) 0))
         (setq *rp:lanes* nil)
         ;; 11. draw order: surface bottom, fills above, all lines and text on top
         (if *rp:hatches* (rp:toback *rp:hatches*))
         (if surf (rp:toback (list surf)))
         ;; 12. store road data on the centre line, then report
         (rp:xput cl
           (list (cons "NAME"  (rp:val "rname"))   (cons "VER"   *rp:ver*)
                 (cons "DATE"  (rp:today))         (cons "FAC"   (rtos fac 2 0))
                 (cons "W"     (rtos (/ w fac) 2 4)) (cons "RIN" (rtos (/ rad0 fac) 2 4))
                 (cons "RREF"  (if (= (rp:val "rref") "1") "0" "1"))  (cons "CHST"  (rp:val "chst"))
                 (cons "CHINT" (rp:val "chint"))   (cons "BLEN"  (rp:val "blen"))
                 (cons "BWID"  (rp:val "bwid"))    (cons "BGAP"  (rp:val "bgap"))
                 (cons "BL"    (rp:pair resL))     (cons "BR"    (rp:pair resR))
                 (cons "BC"    (rp:pair resC))     (cons "BE"    (rp:pair resE))
                 (cons "SPEED" (rtos (rp:num "speed") 2 0))
                 (cons "NCHV"  (itoa nChv))        (cons "NARR"  (itoa nArr))
                 (cons "NCLS"  (itoa nCls))        (cons "ENDS"  ends)
                 (cons "ENDF"  endf)               (cons "NCHM"  (itoa (if nch nch 0)))
                 (cons "TWOWAY" (rp:val "twoway"))
                 (cons "RMODE" (rp:val "rmode"))   (cons "ETYPE" et)  (cons "CTYPE" ct)
                 (cons "EL" (if (rp:on "bl") "1" "0")) (cons "ER" (if (rp:on "br") "1" "0"))
                 (cons "EQL" eqL) (cons "EQR" eqR) (cons "EQC" eqC)
                 (cons "CMARK" (rp:val "cmark")) (cons "SSET" (rp:val "sset"))
                 (cons "NDELI" (itoa *rp:ndeli*))
                 (cons "CARR" (rp:val "ccarr")) (cons "LMODE" (rp:val "clmode"))
                 (cons "NL" (itoa (nth 1 plan))) (cons "NR" (itoa (nth 2 plan)))
                 (cons "LW" (rtos (nth 3 plan) 2 3)) (cons "MW" (rtos (nth 4 plan) 2 3))
                 (cons "MO" (rtos (nth 5 plan) 2 4)) (cons "MED" (rp:val "cmed"))))
         (vlax-ldata-put obj "ROADPRO_SIGNS" sched)
         (vlax-ldata-put obj "ROADPRO_SET" (rp:snapshot))
         (if (rp:corr-any) (rp:corr-run cl))
         (if (rp:on "mark") (rp:mark-run cl))
         (if *rp:conc* (rp:pave-run cl))
         (rp:report-make cl (rp:on "report"))
         ;; 13. typical cross section
         (if (rp:on "xsec") (rp:xsec-run cl "0"))
         (rp:track cl mark0)
         (rp:run-done cl))))))

;;----------------------------------------------------------------------------
;;  CROSS SECTIONS
;;  Drawn true size (1 unit = 1 m, or 1 mm for mm drawings), looking in the
;;  direction of increasing chainage : the road's LEFT side is on the LEFT.
;;----------------------------------------------------------------------------
(setq *rp:xdcl*
 (list
  "roadxsec : dialog {"
  "  label = \"ROAD PRO  -  Cross Section\";"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Section\";"
  "      : popup_list { key = \"xmode\";  label = \"Draw:\";                      edit_width = 26; }"
  "      : edit_box   { key = \"xch\";    label = \"Chainage (m):\";              edit_width = 8; }"
  "      : edit_box   { key = \"xint\";   label = \"Interval (m):\";              edit_width = 8; }"
  "      : edit_box   { key = \"xcf\";    label = \"Crossfall (%):\";             edit_width = 8; }"
  "      : popup_list { key = \"xcamb\";  label = \"Crossfall type:\";            edit_width = 26; }"
  "      : edit_box   { key = \"xverge\"; label = \"Verge beyond barricade (m):\"; edit_width = 8; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Pavement layers (thickness 0 = not used)\";"
  "      : row { : edit_box { key = \"xl1n\"; label = \"1\"; edit_width = 26; }"
  "              : edit_box { key = \"xl1t\"; label = \"t (m)\"; edit_width = 6; } }"
  "      : row { : edit_box { key = \"xl2n\"; label = \"2\"; edit_width = 26; }"
  "              : edit_box { key = \"xl2t\"; label = \"t (m)\"; edit_width = 6; } }"
  "      : row { : edit_box { key = \"xl3n\"; label = \"3\"; edit_width = 26; }"
  "              : edit_box { key = \"xl3t\"; label = \"t (m)\"; edit_width = 6; } }"
  "    }"
  "  }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Barricade profile (red / white, black outline)\";"
  "      : popup_list { key = \"xbtype\"; label = \"Type:\";       edit_width = 26; }"
  "      : edit_box   { key = \"xbh\";    label = \"Height (m):\"; edit_width = 8; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Sign post\";"
  "      : toggle   { key = \"xsign\";   label = \"Show sign post with height\"; }"
  "      : edit_box { key = \"xsclr\";   label = \"Clearance to sign (m):\"; edit_width = 8; }"
  "      : edit_box { key = \"xsplate\"; label = \"Sign size (m):\";         edit_width = 8; }"
  "    }"
  "  }"
  "  spacer;"
  "  ok_cancel;"
  "  errtile;"
  "}"))

(defun rp:xdlg-modes ()
  (mode_tile "xch"  (if (= (get_tile "xmode") "1") 0 1))
  (mode_tile "xint" (if (= (get_tile "xmode") "2") 0 1))
  (foreach k '("xsclr" "xsplate") (mode_tile k (if (= (get_tile "xsign") "1") 0 1))))

(defun rp:xdlg-accept (/ bad v)
  (foreach k '(("xch" "Chainage" 1) ("xint" "Interval" 0) ("xcf" "Crossfall" 1)
               ("xverge" "Verge" 1) ("xl1t" "Layer 1 thickness" 1) ("xl2t" "Layer 2 thickness" 1)
               ("xl3t" "Layer 3 thickness" 1) ("xbh" "Barricade height" 0)
               ("xsclr" "Sign clearance" 0) ("xsplate" "Sign size" 0))
    (if (not bad)
      (progn
        (setq v (rp:dist (get_tile (car k))))
        (if (or (null v) (if (= (caddr k) 1) (< v 0.0) (<= v 0.0)))
          (setq bad k)))))
  (if bad
    (progn
      (set_tile "error" (strcat (cadr bad)
                                (if (= (caddr bad) 1)
                                  " must be zero or a positive number."
                                  " must be a number greater than zero.")))
      (mode_tile (car bad) 2))
    (progn
      (foreach k *rp:xkeys* (rp:set k (get_tile k)))
      (done_dialog 1))))

(defun rp:xdialog (/ fn f id res)
  (setq fn (vl-filename-mktemp "roadxsec.dcl"))
  (if (setq f (open fn "w"))
    (progn
      (foreach l *rp:xdcl* (write-line l f))
      (close f)
      (setq id (load_dialog fn))
      (if (and id (not (minusp id)) (new_dialog "roadxsec" id))
        (progn
          (rp:fill "xmode"  '("Typical cross section" "At one chainage" "At every chainage interval"))
          (rp:fill "xcamb"  '("Camber (falls both sides)" "One-way, falls to right" "One-way, falls to left"))
          (rp:fill "xbtype" '("Water-filled plastic barrier" "New Jersey concrete barrier"))
          (foreach k *rp:xkeys* (set_tile k (rp:val k)))
          (rp:xdlg-modes)
          (foreach k '("xmode" "xsign") (action_tile k "(rp:xdlg-modes)"))
          (action_tile "accept" "(rp:xdlg-accept)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq res (if (= (start_dialog) 1) 'ok 'cancel)))
        (setq res 'fail))
      (if (and id (not (minusp id))) (unload_dialog id))
      (vl-file-delete fn))
    (setq res 'fail))
  res)

;; ---- local section coordinates -> drawing ----
(defun rp:xp (x y) (list (+ (car *rp:xo*) x) (+ (cadr *rp:xo*) y)))

(defun rp:xpl (pts lay closed)
  (rp:mkpl (mapcar '(lambda (p) (list (rp:xp (car p) (cadr p)) 0.0)) pts) lay 0.0 closed))

(defun rp:xline (a b lay) (rp:line (rp:xp (car a) (cadr a)) (rp:xp (car b) (cadr b)) lay 0.0))

(defun rp:xtext (str p h) (rp:ltext str (rp:xp (car p) (cadr p)) h "ROAD-XSEC-TEXT"))

(defun rp:xmtext (str p h / mt)
  (setq mt (vla-AddMText *rp:spc* (rp:p3 (rp:xp (car p) (cadr p)) 0.0) 0.0 str))
  (vla-put-Height mt h)
  (vla-put-AttachmentPoint mt acAttachmentPointMiddleCenter)
  (vla-put-InsertionPoint mt (rp:p3 (rp:xp (car p) (cadr p)) 0.0))
  (vla-put-Layer mt "ROAD-XSEC-TEXT")
  mt)

;; finished surface level at x (0 at the centre line), level beyond the edges
(defun rp:ys (x / mw mo)
  (setq x  (max (- *rp:xhw*) (min *rp:xhw* x))
        mw (if *rp:xc* (car *rp:xc*) 0.0)
        mo (if *rp:xc* (cadr *rp:xc*) 0.0))
  (cond ((= *rp:ct* "1") (* -1.0 *rp:cf* x))
        ((= *rp:ct* "2") (* *rp:cf* x))
        ((> mw 0.0) (* -1.0 *rp:cf* (max 0.0 (- (abs (- x mo)) (* 0.5 mw)))))
        (T (* -1.0 *rp:cf* (abs x)))))

;; carriageway top line shifted by dy
(defun rp:xsurf (dy / mw mo)
  (setq mw (if *rp:xc* (car *rp:xc*) 0.0) mo (if *rp:xc* (cadr *rp:xc*) 0.0))
  (cond
   ((and (= *rp:ct* "0") (> mw 0.0))
    (list (list (- *rp:xhw*) (+ (rp:ys (- *rp:xhw*)) dy)) (list (- mo (* 0.5 mw)) dy) (list (+ mo (* 0.5 mw)) dy)
          (list *rp:xhw* (+ (rp:ys *rp:xhw*) dy))))
   ((= *rp:ct* "0")
    (list (list (- *rp:xhw*) (+ (rp:ys (- *rp:xhw*)) dy)) (list 0.0 dy) (list *rp:xhw* (+ (rp:ys *rp:xhw*) dy))))
   (T
    (list (list (- *rp:xhw*) (+ (rp:ys (- *rp:xhw*)) dy)) (list *rp:xhw* (+ (rp:ys *rp:xhw*) dy))))))

(defun rp:xlay (kn kt fac) (if (> (rp:num kt) 0.0) (list (rp:val kn) (* fac (rp:num kt)))))

;; Pavement layers (name thickness [fill layer]) : concrete road = slab, stone
;; base, earthwork (v3.5); otherwise the asphalt layers of the RDX dialog
(defun rp:xlayers (fac)
  (if (rp:conc-p)
    (vl-remove nil
      (list (if (> (rp:cn "pcont") 0.0)
              (list (strcat "CONCRETE SLAB " (rp:cv "pcong") (if (= (rp:cv "ptype") "2") " (JRCP)" " (JPCP)"))
                    (* fac (rp:cn "pcont")) "ROAD-XSEC-PCC"))
            (if (> (rp:cn "pbaset") 0.0) (list (rp:cv "pbasen") (* fac (rp:cn "pbaset")) "ROAD-XSEC-L2"))
            (if (> (rp:cn "peart") 0.0) (list (rp:cv "pearn") (* fac (rp:cn "peart")) "ROAD-XSEC-EARTH"))))
    (vl-remove nil (list (rp:xlay "xl1n" "xl1t" fac) (rp:xlay "xl2n" "xl2t" fac) (rp:xlay "xl3n" "xl3t" fac)))))

(defun rp:xthk (fac / tt) (setq tt 0.0) (foreach l (rp:xlayers fac) (setq tt (+ tt (cadr l)))) tt)

(defun rp:dim (p1 p2 loc rot th fac / d)
  (setq d (vla-AddDimRotated *rp:spc*
            (rp:p3 (rp:xp (car p1) (cadr p1)) 0.0)
            (rp:p3 (rp:xp (car p2) (cadr p2)) 0.0)
            (rp:p3 (rp:xp (car loc) (cadr loc)) 0.0)
            rot))
  (vla-put-Layer d "ROAD-XSEC-DIM")
  (foreach pr (list (list 'vla-put-TextHeight th)
                    (list 'vla-put-ArrowheadSize (* 0.6 th))
                    (list 'vla-put-ExtensionLineExtension (* 0.4 th))
                    (list 'vla-put-ExtensionLineOffset (* 0.3 th))
                    (list 'vla-put-TextGap (* 0.25 th))
                    (list 'vla-put-PrimaryUnitsPrecision
                          (if (= fac 1.0) acDimPrecisionTwo acDimPrecisionZero))
                    (list 'vla-put-Arrowhead1Type (if (numberp acArrowArchTick) acArrowArchTick 4))
                    (list 'vla-put-Arrowhead2Type (if (numberp acArrowArchTick) acArrowArchTick 4))
                    (list 'vla-put-DimensionLineExtension (* 0.25 th)))
    (vl-catch-all-apply (car pr) (list d (cadr pr))))
  d)

;; barricade profile, base centre (cx,by), base width bw, height bh
(defun rp:xbar (cx by bw bh lay / prof)
  (setq prof (if (= (rp:val "xbtype") "1")
               '((-0.5 0.0) (0.5 0.0) (0.5 0.09) (0.38 0.4) (0.12 1.0) (-0.12 1.0) (-0.38 0.4) (-0.5 0.09))
               '((-0.5 0.0) (0.5 0.0) (0.5 0.12) (0.32 0.2) (0.25 0.92) (0.15 1.0)
                 (-0.15 1.0) (-0.25 0.92) (-0.32 0.2) (-0.5 0.12))))
  (rp:solidfill (rp:xpl (mapcar '(lambda (p) (list (+ cx (* bw (car p))) (+ by (* bh (cadr p))))) prof)
                        "ROAD-BARRIER-OUTLINE" T)
                nil lay 0.0))

;; Edge treatment profile in section : "0" barricade, "1" traffic cone, "2" kerb
(defun rp:xedge (cx by bw bh typ lay fac / k)
  (cond
    ((= typ "1")
     (setq k (* 0.75 fac))
     (rp:solidfill (rp:xpl (list (list (- cx (* 0.5 bw)) by) (list (+ cx (* 0.5 bw)) by)
                                 (list (+ cx (* 0.5 bw)) (+ by (* 0.04 fac))) (list (- cx (* 0.5 bw)) (+ by (* 0.04 fac))))
                           "ROAD-BARRIER-OUTLINE" T)
                   nil "ROAD-BARRIER-OUTLINE" 0.0)
     (rp:solidfill (rp:xpl (list (list (- cx (* 0.35 bw)) (+ by (* 0.04 fac))) (list (+ cx (* 0.35 bw)) (+ by (* 0.04 fac)))
                                 (list (+ cx (* 0.08 bw)) (+ by k)) (list (- cx (* 0.08 bw)) (+ by k)))
                           "ROAD-BARRIER-OUTLINE" T)
                   nil "ROAD-CONE" 0.0)
     (foreach bd '((0.40 0.50) (0.62 0.70))
       (rp:solidfill (rp:xpl (list (list (- cx (* bw (- 0.35 (* 0.27 (car bd))))) (+ by (* k (car bd))))
                                   (list (+ cx (* bw (- 0.35 (* 0.27 (car bd))))) (+ by (* k (car bd))))
                                   (list (+ cx (* bw (- 0.35 (* 0.27 (cadr bd))))) (+ by (* k (cadr bd))))
                                   (list (- cx (* bw (- 0.35 (* 0.27 (cadr bd))))) (+ by (* k (cadr bd)))))
                             "ROAD-BARRIER-OUTLINE" T)
                     nil "ROAD-BARRIER-WHITE" 0.0)))
    ((= typ "2")
     (rp:solidfill (rp:xpl (list (list (- cx (* 0.5 bw)) (- by (* 0.30 fac))) (list (+ cx (* 0.5 bw)) (- by (* 0.30 fac)))
                                 (list (+ cx (* 0.5 bw)) (+ by (* 0.15 fac))) (list (- cx (* 0.5 bw)) (+ by (* 0.15 fac))))
                           "ROAD-BARRIER-OUTLINE" T)
                   nil "ROAD-XSEC-CONC" 0.0))
    (T (rp:xbar cx by bw bh lay))))

;; crossfall arrow + % text, dir +1 falls to the right, -1 to the left
(defun rp:xfall (x dir th fac / y1 y2 p1 p2 pm)
  (setq p1 (list (- x (* dir 0.7 fac)) (+ (rp:ys (- x (* dir 0.7 fac))) (* 0.35 fac)))
        p2 (list (+ x (* dir 0.7 fac)) (+ (rp:ys (+ x (* dir 0.7 fac))) (* 0.35 fac)))
        pm (rp:towards p2 p1 (* 0.25 fac)))
  (rp:mkwpl (list (list (rp:xp (car p1) (cadr p1)) 0.0 0.0)
                  (list (rp:xp (car pm) (cadr pm)) (* 0.12 fac) 0.0)
                  (list (rp:xp (car p2) (cadr p2)) 0.0 0.0))
            "ROAD-XSEC-TEXT" 0.0)
  (rp:xmtext (strcat (rtos (rp:num "xcf") 2 1) "%") (list x (+ (rp:ys x) (* 0.35 fac) (* 1.2 th))) th))

;; sign post with footing and sign face; dims = T adds clearance dimension + note
(defun rp:xpost (px py sclr spl spd fac th dims / po)
  (rp:solidfill (rp:xpl (list (list (- px (* 0.2 fac)) py) (list (+ px (* 0.2 fac)) py)
                              (list (+ px (* 0.2 fac)) (- py (* 0.6 fac)))
                              (list (- px (* 0.2 fac)) (- py (* 0.6 fac))))
                        "ROAD-XSEC" T)
                nil "ROAD-XSEC-CONC" 0.0)
  (setq po (rp:xpl (list (list px (- py (* 0.5 fac))) (list px (+ py sclr))) "ROAD-SIGN" nil))
  (vla-put-ConstantWidth po (* 0.076 fac))
  (rp:sign-speed (rp:xp px (+ py sclr (* 0.5 spl))) spl spd 0.0)
  (if dims
    (progn
      (rp:dim (list px py) (list px (+ py sclr)) (list (+ px (* 0.5 spl) (* 0.6 fac)) py) (* 0.5 pi) th fac)
      (rp:xtext (strcat "TRAFFIC SIGN " (rtos (/ spl fac) 2 2) " m ON 76 mm POST")
                (list (+ px (* 0.5 spl) (* 1.4 fac)) (+ py sclr (* 0.5 spl))) th)
      (rp:xtext "WITH CONCRETE FOOTING 0.40 x 0.60 m"
                (list (+ px (* 0.5 spl) (* 1.4 fac)) (- (+ py sclr (* 0.5 spl)) (* 1.6 th))) th))))

;; One complete cross section with its origin (CL, finished level) at org
(defun rp:xsection (org hw bgap bwid bl br bc fac two spd title note
                    / th bh vg sclr spl lys tt yL yR xl xr xo1 xo2 ybot d0 d1 i pg ytx xt
                      gx1 gx2 x ln top xs ys2 yd1 yd2 yd3 cxL cxR btxt ny hh)
  (setq *rp:xo*  org
        *rp:cf*  (/ (rp:num "xcf") 100.0)
        *rp:ct*  (rp:val "xcamb")
        *rp:xhw* hw
        th   (* 0.2 fac (rp:num "txth"))
        bh   (* fac (rp:num "xbh"))
        vg   (* fac (rp:num "xverge"))
        sclr (* fac (rp:num "xsclr"))
        spl  (* fac (rp:num "xsplate"))
        lys  (rp:xlayers fac)
        tt   (rp:xthk fac)
        yL   (rp:ys (- hw))
        yR   (rp:ys hw)
        xl   (+ hw (if bl (+ bgap bwid) 0.0))
        xr   (+ hw (if br (+ bgap bwid) 0.0))
        ;; v3.6 : the section stops at the corridor limit (outer corridor item),
        ;; or at the verge edge when the side has no corridor items
        xo1  (- (if (> (rp:xc-ext2 1.0) 0.0) (max xl (+ hw (rp:xc-ext2 1.0))) (+ xl vg)))
        xo2  (if (> (rp:xc-ext2 -1.0) 0.0) (max xr (+ hw (rp:xc-ext2 -1.0))) (+ xr vg))
        ybot (- (min yL yR) tt)
        xt   (+ xo2 (* 2.0 fac))
        ny   0)
  (if (rp:xc-has "UT") (setq ybot (min ybot (- (min yL yR) (* 1.25 fac)))))
  (setq *rp:xtier* (+ (max yL yR) (max bh (if (rp:on "xsign") (+ sclr spl) 0.0)) (* 1.0 fac)))
  ;; ---- shoulders / verges ----
  (if (> tt 0.0)
    (progn
      (rp:solidfill (rp:xpl (list (list (- hw) yL) (list xo1 yL) (list xo1 (- yL tt))
                                  (list (- hw) (- yL tt)))
                            "ROAD-XSEC" T)
                    nil "ROAD-XSEC-SHLD" 0.0)
      (rp:solidfill (rp:xpl (list (list hw yR) (list xo2 yR) (list xo2 (- yR tt))
                                  (list hw (- yR tt)))
                            "ROAD-XSEC" T)
                    nil "ROAD-XSEC-SHLD" 0.0)))
  ;; ---- pavement layers with labels ----
  (setq d0 0.0 i 0)
  (foreach l lys
    (setq i  (1+ i)
          d1 (+ d0 (cadr l))
          pg (append (rp:xsurf (- d0)) (reverse (rp:xsurf (- d1)))))
    (rp:solidfill (rp:xpl pg "ROAD-XSEC" T) nil (if (caddr l) (caddr l) (strcat "ROAD-XSEC-L" (itoa i))) 0.0)
    (setq ytx (- (+ yR (* 0.8 fac)) (* ny 2.0 th)) ny (1+ ny))
    (rp:xline (list (* 0.6 hw) (- (rp:ys (* 0.6 hw)) (* 0.5 (+ d0 d1)))) (list (- xt (* 0.3 fac)) ytx)
              "ROAD-XSEC-THIN")
    (rp:xtext (strcat (rtos (/ (* 1000.0 (cadr l)) fac) 2 0) " mm  " (car l)) (list xt ytx) th)
    (setq d0 d1))
  ;; v3.5 concrete : dowels, tie bars, mesh
  (if (and lys (rp:conc-p)) (setq ny (rp:xsteel hw fac th lys xt yR ny)))
  (if (> tt 0.0)
    (progn
      (setq ytx (- (+ yR (* 0.8 fac)) (* ny 2.0 th)) ny (1+ ny))
      (rp:xline (list (* 0.5 (+ xr xo2)) (- yR (* 0.5 tt))) (list (- xt (* 0.3 fac)) ytx) "ROAD-XSEC-THIN")
      (rp:xtext "COMPACTED SHOULDER / VERGE" (list xt ytx) th)))
  (setq ytx (- (+ yR (* 0.8 fac)) (* ny 2.0 th)) ny (1+ ny))
  (rp:xline (list (- xo2 (* 0.4 fac)) (- yR tt)) (list (- xt (* 0.3 fac)) ytx) "ROAD-XSEC-THIN")
  (rp:xtext "SUBGRADE - COMPACTED" (list xt ytx) th)
  ;; ---- finished surface line ----
  (setq ln (rp:xpl (append (list (list xo1 yL)) (rp:xsurf 0.0) (list (list xo2 yR))) "ROAD-XSEC" nil))
  (vla-put-ConstantWidth ln (* 0.02 fac))
  ;; ---- subgrade line, closed at the corridor limits (v3.6) ----
  (rp:xpl (append (list (list xo1 yL) (list xo1 (- yL tt)))
                  (rp:xsurf (- tt))
                  (list (list xo2 (- yR tt)) (list xo2 yR)))
          "ROAD-XSEC" nil)
  ;; ---- paved shoulders ----
  (if (> bgap 0.0)
    (progn
      (setq d1 (if (and lys (or (not (rp:conc-p)) (rp:con "psh"))) (cadr (car lys)) (* 0.05 fac)))
      (rp:solidfill (rp:xpl (list (list (- hw) yL) (list (- (+ hw bgap)) yL) (list (- (+ hw bgap)) (- yL d1))
                                  (list (- hw) (- yL d1))) "ROAD-XSEC" T) nil
                    (if (and (rp:conc-p) (rp:con "psh")) "ROAD-XSEC-PCC" "ROAD-XSEC-L1") 0.0)
      (rp:solidfill (rp:xpl (list (list hw yR) (list (+ hw bgap) yR) (list (+ hw bgap) (- yR d1))
                                  (list hw (- yR d1))) "ROAD-XSEC" T) nil
                    (if (and (rp:conc-p) (rp:con "psh")) "ROAD-XSEC-PCC" "ROAD-XSEC-L1") 0.0)
      (setq ytx (- (+ yR (* 0.8 fac)) (* ny 2.0 th)) ny (1+ ny))
      (rp:xline (list (+ hw (* 0.5 bgap)) (- yR (* 0.5 d1))) (list (- xt (* 0.3 fac)) ytx) "ROAD-XSEC-THIN")
      (rp:xtext (strcat "PAVED SHOULDER " (rtos (/ bgap fac) 2 2) " m") (list xt ytx) th)))
  ;; ---- edge treatment with height : barricade / cone / kerb ----
  (setq cxL  (- (+ hw bgap (* 0.5 bwid)))
        cxR  (+ hw bgap (* 0.5 bwid))
        hh   (cond ((= *rp:xet* "1") (* 0.75 fac)) ((= *rp:xet* "2") (* 0.15 fac)) (T bh))
        btxt (cond ((= *rp:xet* "1") "TRAFFIC CONE")
                   ((= *rp:xet* "2") "KERB STONE")
                   ((= (rp:val "xbtype") "1") "NEW JERSEY CONCRETE BARRIER (RED / WHITE)")
                   (T "WATER-FILLED BARRIER (RED / WHITE)")))
  (if bl (rp:xedge cxL yL bwid bh *rp:xet* "ROAD-BARRIER-RED" fac))
  (if br (rp:xedge cxR yR bwid bh *rp:xet* "ROAD-BARRIER-WHITE" fac))
  (if bc (rp:xedge 0.0 0.0 bwid bh (if (= *rp:xct* "2") "1" "0") "ROAD-BARRIER-RED" fac))
  (cond
    (bl
     (rp:dim (list (- cxL (* 0.5 bwid)) yL) (list (- cxL (* 0.5 bwid)) (+ yL hh))
             (list (- cxL (* 0.5 bwid) (* 0.6 fac)) yL) (* 0.5 pi) th fac)
     ;; v3.6 note moved towards the road with a leader (clear of the sign post)
     (rp:xline (list cxL (+ yL (max hh (* 0.3 fac)))) (list (+ cxL (* 1.6 fac)) (+ yL (max hh bh) (* 0.9 th))) "ROAD-XSEC-THIN")
     (rp:xmtext (strcat btxt "\\PH = " (rtos (/ hh fac) 2 2) " m" (if (= *rp:xet* "2") " UPSTAND" ""))
                (list (+ cxL (* 1.6 fac)) (+ yL (max hh bh) (* 2.2 th))) th))
    (br
     (rp:dim (list (+ cxR (* 0.5 bwid)) yR) (list (+ cxR (* 0.5 bwid)) (+ yR hh))
             (list (+ cxR (* 0.5 bwid) (* 0.6 fac)) yR) (* 0.5 pi) th fac)
     (rp:xline (list cxR (+ yR (max hh (* 0.3 fac)))) (list (- cxR (* 1.6 fac)) (+ yR (max hh bh) (* 0.9 th))) "ROAD-XSEC-THIN")
     (rp:xmtext (strcat btxt "\\PH = " (rtos (/ hh fac) 2 2) " m" (if (= *rp:xet* "2") " UPSTAND" ""))
                (list (- cxR (* 1.6 fac)) (+ yR (max hh bh) (* 2.2 th))) th)))
  (if bc
    (rp:xmtext (strcat "MEDIAN " (if (= *rp:xct* "2") "TRAFFIC CONES" "BARRICADE"))
               (list 0.0 (+ bh (* 3.5 th))) th))
  ;; ---- v3.4 median, sidewalks, walkways, drains, utilities ----
  (if *rp:xc* (rp:xcorr hw yL yR fac th))
  ;; ---- sign posts with clearance height ----
  (if (rp:on "xsign")
    (progn
      (rp:xpost (+ xr (* 0.5 fac)) yR sclr spl spd fac th T)
      (if two (rp:xpost (- (+ xl (* 0.5 fac))) yL sclr spl spd fac th nil))))
  ;; ---- centre line ----
  (setq top (+ (max bh (if (rp:on "xsign") (+ sclr spl) 0.0)) (* 0.8 fac))
        ln  (rp:xline (list 0.0 (- ybot (* 0.4 fac))) (list 0.0 top) "ROAD-CL"))
  (vla-put-LinetypeScale ln (/ (* 0.12 fac) (getvar "LTSCALE")))
  (rp:xmtext "CL" (list 0.0 (+ top (* 1.0 th))) (* 1.4 th))
  ;; ---- crossfall ----
  (if (> *rp:cf* 0.0)
    (if (= *rp:ct* "0")
      (progn (rp:xfall (* -0.5 hw) -1.0 th fac) (rp:xfall (* 0.5 hw) 1.0 th fac))
      (rp:xfall 0.0 (if (= *rp:ct* "1") 1.0 -1.0) th fac)))
  ;; ---- corridor limit markers (v3.6) ----
  (foreach lm (list (list xo1 yL (> (rp:xc-ext2 1.0) 0.0) 1.0) (list xo2 yR (> (rp:xc-ext2 -1.0) 0.0) -1.0))
    (rp:xline (list (car lm) (- ybot (* 0.4 fac))) (list (car lm) top) "ROAD-XSEC-LIMIT")
    (rp:xvtext (if (caddr lm) "CORRIDOR LIMIT" "FORMATION LIMIT")
               (list (- (car lm) (* (cadddr lm) 0.9 th)) (- top (* 4.5 th))) (* 0.8 th)))
  ;; ---- professional dimensions (v3.6) ----
  ;; row 1 : every component with its name, row 2 : roadside / carriageway /
  ;; roadside, row 3 : overall corridor, then the offset / level table
  (setq xs (rp:xc-dims (vl-remove nil (list xo1
                                (if bl (- xl)) (if bl (- (+ hw bgap)))
                                (- hw) 0.0 hw
                                (if br (+ hw bgap)) (if br xr)
                                xo2)) hw)
        yd1 (- ybot (* 1.2 fac))
        yd2 (- yd1 (* 1.3 fac))
        yd3 (- yd2 (* 1.3 fac)))
  (setq d0 xs)
  (while (cdr d0)
    (if (> (- (cadr d0) (car d0)) 1e-6)
      (rp:xdimrow (car d0) (cadr d0) yd1
                  (rp:xseg-name (car d0) (cadr d0) hw bgap bwid bl br (* 0.8 th)) (* 0.8 th) fac))
    (setq d0 (cdr d0)))
  (if (> (- (- hw) xo1) 1e-6) (rp:xdimrow xo1 (- hw) yd2 "LEFT ROADSIDE" th fac))
  (rp:xdimrow (- hw) hw yd2 "CARRIAGEWAY" th fac)
  (if (> (- xo2 hw) 1e-6) (rp:xdimrow hw xo2 yd2 "RIGHT ROADSIDE" th fac))
  (rp:xdimrow xo1 xo2 yd3 (if (> (rp:xc-ext) 0.0) "CORRIDOR WIDTH (LIMIT TO LIMIT)" "TOTAL FORMATION") th fac)
  (setq d1 (rp:xtable xs (- yd3 (* 1.2 fac)) xo1 xo2 th fac))
  ;; ---- title ----
  (rp:xmtext (strcat "{\\L" title "}") (list 0.0 (- d1 (* 1.3 fac))) (* 1.6 th))
  (rp:xmtext (strcat (if (/= note "") (strcat note "\\P") "")
                     "Looking towards increasing chainage  |  1 unit = 1 "
                     (if (= fac 1.0) "m" "mm") "  |  True scale  |  Levels relative to CL finished level")
             (list 0.0 (- d1 (* 1.3 fac) (* 2.8 th))) (* 0.9 th))
  (setq *rp:xtier* nil)
  (princ))

;; ---- v3.6 section helpers ----
;; is a corridor item of kind k (SW WK DR UT) in the section
(defun rp:xc-has (k / r)
  (if *rp:xc* (foreach c (nth 6 *rp:xc*) (if (= (car c) k) (setq r T))))
  r)

;; text rotated 90 degrees, centred on p
(defun rp:xvtext (str p h / mt)
  (setq mt (rp:xmtext str p h))
  (vla-put-Rotation mt (* 0.5 pi))
  mt)

;; signed value with 3 decimals : +3.650 / -0.091 / 0.000
(defun rp:sgn3 (v)
  (strcat (cond ((> v 0.0005) "+") ((< v -0.0005) "-") (T "")) (rtos (abs v) 2 3)))

;; one horizontal dimension between x1 and x2 on the finished line, line at
;; level y, with the component name under the dimension line
(defun rp:xdimrow (x1 x2 y nm th fac / d)
  (setq d (rp:dim (list x1 (rp:ys x1)) (list x2 (rp:ys x2)) (list (* 0.5 (+ x1 x2)) y) 0.0 th fac))
  (if (and nm (/= nm ""))
    (vl-catch-all-apply 'vla-put-TextOverride (list d (strcat "<>\\X" nm))))
  d)

;; name of the section component between x1 and x2 (short name when narrow)
(defun rp:xseg-name (x1 x2 hw bgap bwid bl br th / xm ax mw mo sg nm w)
  (setq xm (* 0.5 (+ x1 x2)) ax (abs xm) w (- x2 x1)
        mw (if *rp:xc* (car *rp:xc*) 0.0) mo (if *rp:xc* (cadr *rp:xc*) 0.0)
        sg (if (< xm 0.0) 1.0 -1.0))
  (cond
    ((and (> mw 0.0) (> xm (- mo (* 0.5 mw))) (< xm (+ mo (* 0.5 mw)))) (setq nm '("MEDIAN" "MED")))
    ((< ax hw) (setq nm '("LANE" "LN")))
    ((and (> bgap 0.0) (< ax (+ hw bgap))) (setq nm '("SHOULDER" "SH")))
    ((and (if (< xm 0.0) bl br) (< ax (+ hw bgap bwid)))
     (setq nm (cond ((= *rp:xet* "1") '("CONES" "TC")) ((= *rp:xet* "2") '("KERB" "K")) (T '("BARRIER" "B"))))))
  (if (and (not nm) *rp:xc*)
    (foreach c (nth 6 *rp:xc*)
      (if (and (not nm) (= (cadr c) sg) (> ax (+ hw (caddr c))) (< ax (+ hw (cadddr c))))
        (setq nm (cdr (assoc (car c) '(("SW" "SIDEWALK" "SW") ("WK" "WALKWAY" "WK")
                                       ("DR" "DRAIN" "DR") ("UT" "UTILITY" "UT"))))))))
  (if (not nm) (setq nm '("VERGE" "VG")))
  (cond ((> w (* 0.9 th (+ 3 (strlen (car nm))))) (car nm))
        ((> w (* 0.9 th (+ 1 (strlen (cadr nm))))) (cadr nm))
        (T "")))

;; offset / finished level table under the dimensions, top at y0;
;; returns the bottom level of the table
(defun rp:xtable (xs y0 xa xb th fac / rh hx ta tb prev)
  (setq rh (* 1.5 fac)
        ta (- xa (* 0.5 fac)) tb (+ xb (* 0.5 fac))
        hx (- ta (* 4.4 fac)))
  (foreach yy (list y0 (- y0 rh) (- y0 rh rh))
    (rp:xline (list hx yy) (list tb yy) "ROAD-XSEC-THIN"))
  (foreach xx (list hx ta tb)
    (rp:xline (list xx y0) (list xx (- y0 rh rh)) "ROAD-XSEC-THIN"))
  (rp:xmtext "OFFSET (m)" (list (* 0.5 (+ hx ta)) (- y0 (* 0.5 rh))) (* 0.8 th))
  (rp:xmtext "FIN. LEVEL (m)" (list (* 0.5 (+ hx ta)) (- y0 (* 1.5 rh))) (* 0.8 th))
  (foreach x xs
    (if (or (null prev) (> (- x prev) (* 1.3 th)))
      (progn
        (rp:xvtext (rp:sgn3 (/ x fac)) (list x (- y0 (* 0.5 rh))) (* 0.7 th))
        (rp:xvtext (rp:sgn3 (/ (rp:ys x) fac)) (list x (- y0 (* 1.5 rh))) (* 0.7 th))
        (rp:xline (list x y0) (list x (- y0 (* 0.12 rh))) "ROAD-XSEC-THIN")
        (setq prev x))))
  (- y0 rh rh))

(defun rp:xnote (d curves strs fac / i r)
  (setq i 0)
  (foreach c curves
    (setq i (1+ i))
    (if (and (not r) (>= d (- (car c) 1e-6)) (<= d (+ (cadr c) 1e-6)))
      (setq r (strcat "On curve C" (itoa i) " - " (if (> (nth 4 c) 0) "left" "right")
                      " bend, R (CL) = " (rtos (/ (nth 2 c) fac) 2 3) " m"))))
  (setq i 0)
  (foreach s strs
    (setq i (1+ i))
    (if (and (not r) (>= d (- (car s) 1e-6)) (<= d (+ (cadr s) 1e-6)))
      (setq r (strcat "On straight S" (itoa i)))))
  (if r r ""))

(defun rp:take (lst n / r) (repeat (min n (length lst)) (setq r (cons (car lst) r) lst (cdr lst))) (reverse r))

;; mode "0" typical / "1" one chainage / "2" every interval
(defun rp:xsec-run (e mode / data fac obj len st hw bl br bc bgap bwid two spd nm curves strs
                       pt ch d dl k iv n vg tt top dx dy lx th)
  (setq data (rp:xget e)
        fac  (atof (rp:xv "FAC" data)))
  (if (<= fac 0.0) (setq fac 1.0))
  (setq obj      (vlax-ename->vla-object e)
        len      (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
        *rp:len* len
        st       (atof (rp:xv "CHST" data))
        hw       (* 0.5 fac (atof (rp:xv "W" data)))
        bl       (or (/= (rp:xv "BL" data) "0,0") (= (rp:xv "EL" data) "1"))
        br       (or (/= (rp:xv "BR" data) "0,0") (= (rp:xv "ER" data) "1"))
        bc       (or (/= (rp:xv "BC" data) "0,0") (member (rp:xv "CTYPE" data) '("1" "2")))
        *rp:xet* (if (= (rp:xv "ETYPE" data) "") "0" (rp:xv "ETYPE" data))
        *rp:xct* (if (= (rp:xv "CTYPE" data) "2") "2" "1")
        bgap     (* fac (atof (rp:xv "BGAP" data)))
        bwid     (* fac (atof (rp:xv "BWID" data)))
        two      (/= (rp:xv "TWOWAY" data) "0")
        spd      (if (= (rp:xv "SPEED" data) "") "30" (rp:xv "SPEED" data))
        nm       (rp:xv "NAME" data)
        curves   (rp:curves obj)
        strs     (rp:straights obj)
        *rp:hatches* nil
        *rp:cset* (vlax-ldata-get obj "ROADPRO_SET"))
  (setq *rp:xc* (list (* fac (atof (rp:xv "MW" data))) (- (* fac (atof (rp:xv "MO" data)))) (rp:xv "MED" data)
                      (atoi (rp:xv "NL" data)) (atoi (rp:xv "NR" data)) (* fac (atof (rp:xv "LW" data)))
                      (if *rp:cset* (rp:corr-layout bgap bwid bl br fac))))
  (cond
    ((= mode "1")
     (setq ch (rp:num "xch")
           d  (* fac (- ch st)))
     (if (or (< d -1e-6) (> d (+ len 1e-6)))
       (alert (strcat "Chainage " (rp:chfmt ch) " is outside this road\n("
                      (rp:chfmt st) " to " (rp:chfmt (+ st (/ len fac))) ")."))
       (if (setq pt (getpoint "\nPick point for the section centre line (finished road level): "))
         (rp:xsection pt hw bgap bwid bl br bc fac two spd
                      (strcat "CROSS SECTION AT CH " (rp:chfmt ch) "  -  " nm)
                      (rp:xnote d curves strs fac)))))
    ((= mode "2")
     (setq iv (* fac (rp:num "xint"))
           dl (list 0.0)
           k  (fix (/ (* st fac) iv))
           d  (- (* (1+ k) iv) (* st fac)))
     (if (< d (* 0.001 iv)) (setq d (+ d iv)))
     (while (< d (- len (* 0.001 iv))) (setq dl (cons d dl) d (+ d iv)))
     (setq dl (reverse (cons len dl)))
     (if (> (length dl) 60)
       (progn (princ "\nMore than 60 sections - only the first 60 are drawn.") (setq dl (rp:take dl 60))))
     (setq vg  (* fac (rp:num "xverge"))
           tt  (rp:xthk fac)
           th  (* 0.2 fac (rp:num "txth"))
           top (+ (max (* fac (rp:num "xbh"))
                       (if (rp:on "xsign") (* fac (+ (rp:num "xsclr") (rp:num "xsplate"))) 0.0))
                  (if (> (rp:xc-ext) 0.0) (+ (* 1.5 fac) (* 12.6 th)) (* 2.5 fac)))
           lx  (+ hw (max (+ bgap bwid) (rp:xc-ext)) vg (* 6.0 fac))
           dx  (+ (* 2.0 lx) (* 32.0 th) (* 4.0 fac))
           dy  (+ top tt (if (rp:xc-has "UT") (* 1.25 fac) 0.0) (* 15.0 fac)))
     (if (setq pt (getpoint (strcat "\nPick top-left corner for " (itoa (length dl)) " cross sections: ")))
       (progn
         (setq n 0)
         (foreach dd dl
           (rp:xsection (list (+ (car pt) (* (rem n 3) dx) lx) (- (cadr pt) top (* (/ n 3) dy)))
                        hw bgap bwid bl br bc fac two spd
                        (strcat "SECTION AT CH " (rp:chfmt (+ st (/ dd fac))))
                        (rp:xnote dd curves strs fac))
           (setq n (1+ n)))
         (princ (strcat "\n  " (itoa n) " cross sections drawn.")))))
    (T
     (if (setq pt (getpoint "\nPick point for the TYPICAL CROSS SECTION centre line <Enter = skip>: "))
       (rp:xsection pt hw bgap bwid bl br bc fac two spd
                    (strcat "TYPICAL CROSS SECTION  -  " nm) ""))))
  (if *rp:hatches* (rp:toback *rp:hatches*))
  (setq *rp:cset* nil *rp:xc* nil)
  (princ))

;;----------------------------------------------------------------------------
;;  LANE WIDENING
;;  Extra lane from a start chainage to an end chainage on the left, right or
;;  both sides, with taper in and taper out.
;;    Taper type  : Straight (linear)  or  Curve (reverse curve, tangent ends)
;;    Match point : Fillet with radius R  or  Direct link (sharp joint)
;;  The geometry is built in station-offset space and mapped onto the centre
;;  line, so it follows straights and curves of the road.
;;----------------------------------------------------------------------------
(setq *rp:wdcl*
 (list
  "roadwiden : dialog {"
  "  label = \"ROAD PRO  -  Lane Widening\";"
  "  : text { key = \"info\"; width = 60; }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Extra lane  (Left side when different)\";"
  "      : popup_list { key = \"wside\"; label = \"Side:\";                 edit_width = 16; }"
  "      : edit_box   { key = \"wwid\";  label = \"Extra width (m):\";      edit_width = 8; }"
  "      : edit_box   { key = \"wst\";   label = \"Start chainage (m):\";   edit_width = 8; }"
  "      : edit_box   { key = \"wen\";   label = \"End chainage (m):\";     edit_width = 8; }"
  "      : edit_box   { key = \"wtin\";  label = \"Taper in length (m):\";  edit_width = 8; }"
  "      : edit_box   { key = \"wtout\"; label = \"Taper out length (m):\"; edit_width = 8; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Right side  (Both sides only)\";"
  "      : toggle   { key = \"wdiff\";  label = \"Different chainage on right side\"; }"
  "      : edit_box { key = \"wwid2\";  label = \"Extra width (m):\";      edit_width = 8; }"
  "      : edit_box { key = \"wst2\";   label = \"Start chainage (m):\";   edit_width = 8; }"
  "      : edit_box { key = \"wen2\";   label = \"End chainage (m):\";     edit_width = 8; }"
  "      : edit_box { key = \"wtin2\";  label = \"Taper in length (m):\";  edit_width = 8; }"
  "      : edit_box { key = \"wtout2\"; label = \"Taper out length (m):\"; edit_width = 8; }"
  "      : edit_box { key = \"wrad2\";  label = \"Fillet radius (m):\";    edit_width = 8; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Taper and match points\";"
  "      : popup_list { key = \"wtype\";  label = \"Taper type:\";  edit_width = 26; }"
  "      : popup_list { key = \"wmatch\"; label = \"Match point:\"; edit_width = 26; }"
  "      : edit_box   { key = \"wrad\";   label = \"Fillet radius (m):\"; edit_width = 8; }"
  "      : toggle { key = \"wbar\"; label = \"Move barricades to the new edge\"; }"
  "      : toggle { key = \"warr\"; label = \"Lane arrow in the new lane\"; }"
  "      : toggle { key = \"wlab\"; label = \"Labels, width dimension, match points\"; }"
  "    }"
  "  }"
  "  spacer;"
  "  ok_cancel;"
  "  errtile;"
  "}"))

(defun rp:wdlg-modes (/ st both)
  (setq st   (= (get_tile "wtype") "0")
        both (= (get_tile "wside") "2"))
  (mode_tile "wmatch" (if st 0 1))
  (mode_tile "wrad" (if (and st (= (get_tile "wmatch") "0")) 0 1))
  (mode_tile "wdiff" (if both 0 1))
  (foreach k '("wwid2" "wst2" "wen2" "wtin2" "wtout2")
    (mode_tile k (if (and both (= (get_tile "wdiff") "1")) 0 1)))
  (mode_tile "wrad2" (if (and both (= (get_tile "wdiff") "1") st (= (get_tile "wmatch") "0")) 0 1)))

(defun rp:wdlg-accept (/ bad v r2)
  (setq r2 (and (= (get_tile "wside") "2") (= (get_tile "wdiff") "1")))
  (foreach k (append
               '(("wwid" "Extra width" 0) ("wst" "Start chainage" 1) ("wen" "End chainage" 1)
                 ("wtin" "Taper in length" 1) ("wtout" "Taper out length" 1) ("wrad" "Fillet radius" 0))
               (if r2 '(("wwid2" "Right extra width" 0) ("wst2" "Right start chainage" 1)
                        ("wen2" "Right end chainage" 1) ("wtin2" "Right taper in length" 1)
                        ("wtout2" "Right taper out length" 1) ("wrad2" "Right fillet radius" 0))))
    (if (not bad)
      (progn
        (setq v (rp:dist (get_tile (car k))))
        (if (or (null v) (if (= (caddr k) 1) (< v 0.0) (<= v 0.0)))
          (setq bad k)))))
  (cond
    (bad
     (set_tile "error" (strcat (cadr bad)
                               (if (= (caddr bad) 1)
                                 " must be zero or a positive number."
                                 " must be a number greater than zero.")))
     (mode_tile (car bad) 2))
    ((<= (rp:dist (get_tile "wen")) (rp:dist (get_tile "wst")))
     (set_tile "error" "End chainage must be greater than the start chainage.")
     (mode_tile "wen" 2))
    ((and r2 (<= (rp:dist (get_tile "wen2")) (rp:dist (get_tile "wst2"))))
     (set_tile "error" "Right side: end chainage must be greater than the start chainage.")
     (mode_tile "wen2" 2))
    (T
     (foreach k *rp:wkeys* (rp:set k (get_tile k)))
     (done_dialog 1))))

(defun rp:wdialog (info / fn f id res)
  (setq fn (vl-filename-mktemp "roadwiden.dcl"))
  (if (setq f (open fn "w"))
    (progn
      (foreach l *rp:wdcl* (write-line l f))
      (close f)
      (setq id (load_dialog fn))
      (if (and id (not (minusp id)) (new_dialog "roadwiden" id))
        (progn
          (rp:fill "wside"  '("Left" "Right" "Both sides"))
          (rp:fill "wtype"  '("Straight (linear) taper" "Curve (reverse-curve) taper"))
          (rp:fill "wmatch" '("Fillet at match points" "Direct link (no fillet)"))
          (foreach k *rp:wkeys* (set_tile k (rp:val k)))
          (set_tile "info" info)
          (rp:wdlg-modes)
          (foreach k '("wtype" "wmatch" "wside" "wdiff") (action_tile k "(rp:wdlg-modes)"))
          (action_tile "accept" "(rp:wdlg-accept)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq res (if (= (start_dialog) 1) 'ok 'cancel)))
        (setq res 'fail))
      (if (and id (not (minusp id))) (unload_dialog id))
      (vl-file-delete fn))
    (setq res 'fail))
  res)

;; ---- profile helpers (station s, offset o) ----
(defun rp:acos (x) (setq x (max -1.0 (min 1.0 x))) (atan (sqrt (- 1.0 (* x x))) x))

(defun rp:unit2 (a b / d)
  (setq d (distance a b))
  (if (< d 1e-12) (list 1.0 0.0) (list (/ (- (car b) (car a)) d) (/ (- (cadr b) (cadr a)) d))))

;; Fillet the corner k between p0-k and k-p1 with radius r : list of arc points
(defun rp:fillet-pts (p0 k p1 r n / u1 u2 cr dl tl t1 sg c a0 i lst)
  (setq u1 (rp:unit2 p0 k)
        u2 (rp:unit2 k p1)
        cr (- (* (car u1) (cadr u2)) (* (cadr u1) (car u2)))
        dl (rp:acos (+ (* (car u1) (car u2)) (* (cadr u1) (cadr u2)))))
  (if (or (< (abs cr) 1e-9) (<= r 0.0))
    (list k)
    (progn
      (setq tl (* r (/ (sin (* 0.5 dl)) (cos (* 0.5 dl))))
            t1 (list (- (car k) (* tl (car u1))) (- (cadr k) (* tl (cadr u1))))
            sg (if (> cr 0.0) 1.0 -1.0)
            c  (list (- (car t1) (* sg r (cadr u1))) (+ (cadr t1) (* sg r (car u1))))
            a0 (angle c t1)
            i  0)
      (repeat (1+ n)
        (setq lst (cons (polar c (+ a0 (* sg dl (/ (float i) n))) r) lst) i (1+ i)))
      (reverse lst))))

;; Reverse-curve taper offset at x along a taper of length tl and width w
(defun rp:rc-o (x tl w / r)
  (setq r (/ (+ (* tl tl) (* w w)) (* 4.0 w)))
  (if (<= x (* 0.5 tl))
    (- r (sqrt (max 0.0 (- (* r r) (* x x)))))
    (- w (- r (sqrt (max 0.0 (- (* r r) (* (- tl x) (- tl x)))))))))

(defun rp:densify (pts step / out a b n i)
  (setq out (list (car pts)) a (car pts))
  (foreach b (cdr pts)
    (setq n (max 1 (fix (+ 0.999999 (/ (distance a b) step)))) i 1)
    (repeat n
      (setq out (cons (list (+ (car a) (* (- (car b) (car a)) (/ (float i) n)))
                            (+ (cadr a) (* (- (cadr b) (cadr a)) (/ (float i) n))))
                      out)
            i   (1+ i)))
    (setq a b))
  (reverse out))

;; Widening profile : dense list of (s o) from the first to the last match point
(defun rp:wprofile (s1 st en s2 w curve rf fac / k pts big n out s)
  (if curve
    (progn
      (setq out (list (list s1 0.0)) s (+ s1 (* 0.25 fac)))
      (while (< s st)
        (setq out (cons (list s (rp:rc-o (- s s1) (- st s1) w)) out) s (+ s (* 0.25 fac))))
      (setq out (cons (list st w) out))
      (setq out (cons (list en w) out) s (+ en (* 0.25 fac)))
      (while (< s s2)
        (setq out (cons (list s (rp:rc-o (- s2 s) (- s2 en) w)) out) s (+ s (* 0.25 fac))))
      (setq out (reverse (cons (list s2 0.0) out)))
      (rp:densify out (* 0.5 fac)))
    (progn
      (setq big (max (* 2.0 rf) fac)
            k   (list (list (- s1 big) 0.0) (list s1 0.0) (list st w) (list en w)
                      (list s2 0.0) (list (+ s2 big) 0.0))
            pts (list (car k)))
      (setq n 1)
      (repeat 4
        (setq pts (append pts
                          (if (> rf 0.0)
                            (rp:fillet-pts (nth (1- n) k) (nth n k) (nth (1+ n) k) rf
                                           (max 6 (fix (/ (* rf 0.4) (* 0.25 fac)))))
                            (list (nth n k))))
              n   (1+ n)))
      (setq pts (append pts (list (last k))))
      ;; drop the lead-in and lead-out on the original edge
      (while (and (cadr pts) (< (abs (cadr (cadr pts))) 1e-7)) (setq pts (cdr pts)))
      (setq pts (reverse pts))
      (while (and (cadr pts) (< (abs (cadr (cadr pts))) 1e-7)) (setq pts (cdr pts)))
      (rp:densify (reverse pts) (* 0.5 fac)))))

;; Offset of the profile at station s (0 outside the widening)
(defun rp:prof-o (pts s / a b r)
  (if (<= s (car (car pts)))
    (cadr (car pts))
    (progn
      (setq a (car pts) pts (cdr pts))
      (while (and pts (not r))
        (setq b (car pts))
        (if (<= s (car b))
          (setq r (if (< (- (car b) (car a)) 1e-9)
                    (cadr b)
                    (+ (cadr a) (* (- (cadr b) (cadr a)) (/ (- s (car a)) (- (car b) (car a))))))))
        (setq a b pts (cdr pts)))
      (if r r 0.0))))

;; Remove barricade units on one side between stations sA and sB
;; returns (red-removed white-removed first-centre last-centre)
(defun rp:wbar-remove (cl sg hw sA sB blen / ss i e o mn mx c p d f lat nr nw dmin dmax lay)
  (setq nr 0 nw 0
        ss (ssget "_X" '((8 . "ROAD-BARRIER-RED,ROAD-BARRIER-WHITE,ROAD-BARRIER-OUTLINE,ROAD-CONE,ROAD-CONE-BAND,ROAD-KERB"))))
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq e (ssname ss i) o (vlax-ename->vla-object e) i (1+ i))
        (vla-GetBoundingBox o 'mn 'mx)
        (setq mn (vlax-safearray->list mn) mx (vlax-safearray->list mx)
              c  (list (* 0.5 (+ (car mn) (car mx))) (* 0.5 (+ (cadr mn) (cadr mx))))
              p  (vlax-curve-getClosestPointTo cl (list (car c) (cadr c) (caddr mn)))
              d  (vlax-curve-getDistAtPoint cl p))
        (if d
          (progn
            (setq f   (rp:frame cl d)
                  lat (+ (* (- (car c) (car (car f))) (car (cadr f)))
                         (* (- (cadr c) (cadr (car f))) (cadr (cadr f)))))
            (if (and (> (* sg lat) hw)
                     (>= d (- sA (* 0.5 blen))) (<= d (+ sB (* 0.5 blen))))
              (progn
                (setq lay (vla-get-Layer o))
                (cond ((= lay "ROAD-BARRIER-RED") (setq nr (1+ nr)))
                      ((= lay "ROAD-BARRIER-WHITE") (setq nw (1+ nw))))
                (if (/= lay "ROAD-BARRIER-OUTLINE")
                  (setq dmin (if dmin (min dmin d) d) dmax (if dmax (max dmax d) d)))
                (vla-Delete o))))))))
  (list nr nw dmin dmax))

;; Barricade units along the widened edge between stations d0 and d1
(defun rp:barrier-prof (cl pts sg hw gap bwid d0 d1 seg step elev k0
                        / d de n i dd o pa pb cnt nred nwht)
  (setq d d0 cnt k0 nred 0 nwht 0)
  (if (= *rp:etype* "1")
    ;; traffic cones along the new edge
    (progn
      (setq d (+ d0 (* 0.5 seg)))
      (while (<= d d1)
        (rp:cone (rp:offpt cl d (* sg (+ hw (rp:prof-o pts d) gap (* 0.5 bwid)))) bwid elev)
        (setq d (+ d seg)))
      (setq d d1)))
  (if (= *rp:etype* "2") (setq *rp:unitfill* "ROAD-KERB"))
  (while (< d (- d1 1e-6))
    (setq de (+ d seg))
    (if (> de (- d1 (* 0.25 seg))) (setq de d1))
    (setq n  (max 1 (fix (+ 0.999999 (/ (- de d) step))))
          pa nil pb nil i 0)
    (repeat (1+ n)
      (setq dd (+ d (* (- de d) (/ (float i) n)))
            o  (rp:prof-o pts dd)
            pa (cons (rp:offpt cl dd (* sg (+ hw o gap))) pa)
            pb (cons (rp:offpt cl dd (* sg (+ hw o gap bwid))) pb)
            i  (1+ i)))
    (rp:solidfill (rp:poly (append (reverse pa) pb) "ROAD-BARRIER-OUTLINE" elev)
                  nil
                  (cond (*rp:unitfill* *rp:unitfill*)
                        ((= 0 (rem cnt 2)) "ROAD-BARRIER-RED")
                        (T "ROAD-BARRIER-WHITE"))
                  elev)
    (if (= 0 (rem cnt 2)) (setq nred (1+ nred)) (setq nwht (1+ nwht)))
    (setq cnt (1+ cnt) d de))
  (setq *rp:unitfill* nil)
  (if (member *rp:etype* '("1" "2")) (list 0 0) (list nred nwht)))

;; Radius mark at station s on an edge at offset eoff : leader arrow + "R=.." text
;; placed on the pavement side of the edge, parallel to the road
(defun rp:rmark (cl s eoff sg rr fac th elev / pe pm pt f ang rot tx)
  (setq pe  (rp:offpt cl s (* sg eoff))
        pm  (rp:offpt cl s (* sg (- eoff (* 1.2 fac))))
        pt  (rp:offpt cl s (* sg (- eoff (* 1.2 fac) (* 0.9 th))))
        f   (rp:frame cl s)
        ang (angle '(0.0 0.0) (caddr f))
        rot (if (and (> ang (* 0.5 pi)) (<= ang (* 1.5 pi))) (+ ang pi) ang))
  (rp:mkwpl (list (list pm 0.0 0.0)
                  (list (rp:towards pe pm (* 0.5 th)) (* 0.25 th) 0.0)
                  (list pe 0.0 0.0))
            "ROAD-WIDENING" elev)
  (setq tx (rp:text (strcat "R=" (rtos (/ rr fac) 2 2)) pt (* 0.7 th) "ROAD-WIDENING" elev))
  (vla-put-Rotation tx rot)
  tx)

;; One side of a widening. Returns (record bar-change surface-hatch)
(defun rp:widen-side (cl id sg hw w s1 st en s2 curve rf fac th elev st0 iv
                      barq bgap bwid blen two
                      / pts wp ep bnd h area edge rmv add k0 sA sB mid f ang rot ip mt
                        dimo p1 p2 kp rows s o pp lbl side tr txt)
  (setq pts (rp:wprofile s1 st en s2 w curve rf fac)
        sA  (car (car pts))
        sB  (car (last pts))
        wp  (mapcar '(lambda (p) (rp:offpt cl (car p) (* sg (+ hw (cadr p))))) pts)
        ep  (mapcar '(lambda (p) (rp:offpt cl (car p) (* sg hw))) pts)
        side (if (> sg 0) "Left" "Right"))
  ;; new road edge
  (setq edge (rp:mkpl (mapcar '(lambda (p) (list p 0.0)) wp) "ROAD-EDGE" elev nil))
  ;; widening surface
  (setq bnd (rp:poly (append wp (reverse (cdr (reverse (cdr (reverse ep)))))) "ROAD-SURFACE" elev)
        h   (rp:newhatch "SOLID" nil elev))
  (vla-put-Layer h "ROAD-SURFACE")
  (vla-AppendOuterLoop h (rp:objarr (list bnd)))
  (vla-Evaluate h)
  (vl-catch-all-apply 'vla-put-EntityTransparency (list h "50"))
  (rp:surf-color h)
  (setq area (vla-get-Area h))
  (vla-Delete bnd)
  ;; barricades moved to the new edge
  (setq add (list 0 0) rmv (list 0 0 nil nil))
  (if barq
    (progn
      (setq rmv (rp:wbar-remove cl sg hw sA sB blen))
      (if (caddr rmv)
        (setq k0  (fix (+ 0.5 (/ (- (caddr rmv) (* 0.5 blen)) blen)))
              add (rp:barrier-prof cl pts sg hw bgap bwid
                                   (max 0.0 (- (caddr rmv) (* 0.5 blen)))
                                   (min *rp:len* (+ (cadddr rmv) (* 0.5 blen)))
                                   blen (min blen (* 0.5 fac)) elev k0)))))
  ;; v3.6 : the paved shoulder moves out with the new edge (no hatch under the new lane)
  (if (> bgap 0.0)
    (progn
      (rp:shld-cut cl sg sA sB fac elev)
      (setq *rp:len* (vlax-curve-getDistAtParam cl (vlax-curve-getEndParam cl)))
      (rp:band-prof cl sA sB sg hw bgap pts "ROAD-SHOULDER" elev fac)))
  ;; lane arrow in the new lane
  (if (and (rp:on "warr") (>= (- en st) (* 12.0 fac)))
    (progn
      (setq f   (rp:frame cl (* 0.5 (+ st en)))
            ang (angle '(0.0 0.0) (caddr f)))
      (rp:arrow (rp:loc f (* sg (+ hw (* 0.5 w))) 0.0)
                (if (and (> sg 0) two) (+ ang pi) ang) fac elev)))
  ;; key points (taper start, full width start / end, taper end)
  (setq kp (list (list (car (car pts)) "TS")))
  (foreach q pts (if (and (>= (cadr q) (- w 1e-6)) (not (assoc "FS" (mapcar 'reverse kp))))
                   (setq kp (cons (list (car q) "FS") kp))))
  (foreach q (reverse pts) (if (and (>= (cadr q) (- w 1e-6)) (not (assoc "FE" (mapcar 'reverse kp))))
                             (setq kp (cons (list (car q) "FE") kp))))
  (setq kp (cons (list (car (last pts)) "TE") kp))
  ;; setting-out rows : key points + every chainage interval
  (if (> iv 0.0)
    (progn
      (setq s (* iv (fix (+ 1.0 (/ (+ sA (* st0 fac)) iv)))))
      (setq s (- s (* st0 fac)))
      (while (< s sB)
        (if (> s sA) (setq kp (cons (list s "CH") kp)))
        (setq s (+ s iv)))))
  (setq kp (vl-sort kp '(lambda (a b) (< (car a) (car b)))))
  (foreach q kp
    (setq o  (rp:prof-o pts (car q))
          pp (rp:offpt cl (car q) (* sg (+ hw o)))
          rows (cons (list (strcat id "-" (if (> sg 0) "L" "R")) (cadr q)
                           (rp:chfmt (+ st0 (/ (car q) fac)))
                           (rtos (/ (* sg (+ hw o)) fac) 2 3)
                           (rtos (/ (car pp) fac) 2 3) (rtos (/ (cadr pp) fac) 2 3))
                     rows)))
  (setq rows (reverse rows))
  ;; labels, dimension, match point markers
  (if (rp:on "wlab")
    (progn
      (foreach q kp
        (if (/= (cadr q) "CH")
          (progn
            (setq o  (rp:prof-o pts (car q))
                  pp (rp:offpt cl (car q) (* sg (+ hw o))))
            (vla-put-Layer (vla-AddCircle *rp:spc* (rp:p3 pp elev) (* 0.3 fac)) "ROAD-WIDENING")
            (rp:sidetext cl (car q) (strcat (cadr q) " " (rp:chfmt (+ st0 (/ (car q) fac))))
                         (* sg (+ hw o (* 0.8 fac))) (* 0.8 th) "ROAD-WIDENING" elev))))
      ;; radius marks : every fillet, or both arcs of each reverse-curve taper
      (if curve
        (foreach q (list (list (+ s1 (* 0.25 (- st s1))) (- st s1)) (list (+ s1 (* 0.75 (- st s1))) (- st s1))
                         (list (+ en (* 0.25 (- s2 en))) (- s2 en)) (list (+ en (* 0.75 (- s2 en))) (- s2 en)))
          (if (> (cadr q) 0.0)
            (rp:rmark cl (car q) (+ hw (rp:prof-o pts (car q))) sg
                      (/ (+ (* (cadr q) (cadr q)) (* w w)) (* 4.0 w)) fac th elev)))
        (if (> rf 0.0)
          (foreach sc (list s1 st en s2)
            (rp:rmark cl sc (+ hw (rp:prof-o pts sc)) sg rf fac th elev))))
      (setq mid (* 0.5 (+ st en))
            p1  (rp:offpt cl mid (* sg hw))
            p2  (rp:offpt cl mid (* sg (+ hw w)))
            f   (rp:frame cl mid)
            dimo (vla-AddDimAligned *rp:spc* (rp:p3 p1 elev) (rp:p3 p2 elev)
                                    (rp:p3 (rp:pt+ (rp:towards p1 p2 (* 0.5 w)) (caddr f) (* 3.0 fac)) elev)))
      (vla-put-Layer dimo "ROAD-WIDENING")
      (foreach pr (list (list 'vla-put-TextHeight (* 0.8 th)) (list 'vla-put-ArrowheadSize (* 0.5 th))
                        (list 'vla-put-PrimaryUnitsPrecision (if (= fac 1.0) acDimPrecisionTwo acDimPrecisionZero)))
        (vl-catch-all-apply (car pr) (list dimo (cadr pr))))
      (setq ang (angle '(0.0 0.0) (caddr f))
            rot (if (and (> ang (* 0.5 pi)) (<= ang (* 1.5 pi))) (+ ang pi) ang)
            ip  (rp:offpt cl mid (* sg (+ hw w bgap bwid (* 1.0 fac) (* 3.0 th))))
            tr  (if curve
                  (strcat "CURVE TAPER (REVERSE CURVE)  R in "
                          (rtos (/ (/ (+ (* (- st s1) (- st s1)) (* w w)) (* 4.0 w)) fac) 2 1) " m  /  R out "
                          (rtos (/ (/ (+ (* (- s2 en) (- s2 en)) (* w w)) (* 4.0 w)) fac) 2 1) " m")
                  (strcat "STRAIGHT TAPER 1:" (rtos (/ (- st s1) w) 2 1) " in, 1:" (rtos (/ (- s2 en) w) 2 1) " out"
                          (if (> rf 0.0) (strcat "  -  FILLET R=" (rtos (/ rf fac) 2 1) " m") "  -  DIRECT LINK")))
            mt  (vla-AddMText *rp:spc* (rp:p3 ip elev) 0.0
                  (strcat "LANE WIDENING " id " (" side ")  +" (rtos (/ w fac) 2 2) " m"
                          "\\PCH " (rp:chfmt (+ st0 (/ st fac))) " - " (rp:chfmt (+ st0 (/ en fac)))
                          "\\PTAPER IN " (rtos (/ (- st s1) fac) 2 1) " m  /  OUT " (rtos (/ (- s2 en) fac) 2 1) " m"
                          "\\P" tr
                          "\\PAREA = " (rtos (/ area fac fac) 2 2) " m\\U+00B2")))
      (vla-put-Height mt (* 0.8 th))
      (vla-put-AttachmentPoint mt acAttachmentPointMiddleCenter)
      (vla-put-InsertionPoint mt (rp:p3 ip elev))
      (vla-put-Rotation mt rot)
      (vla-put-Layer mt "ROAD-WIDENING")))
  (list (list (strcat id "-" (if (> sg 0) "L" "R")) side (rtos (/ w fac) 2 2)
              (rp:chfmt (+ st0 (/ st fac))) (rp:chfmt (+ st0 (/ en fac)))
              (rtos (/ (- st s1) fac) 2 1) (rtos (/ (- s2 en) fac) 2 1)
              (if curve "Curve (reverse curve)" "Straight")
              (if curve "Tangent (curve)" (if (> rf 0.0) (strcat "Fillet R " (rtos (/ rf fac) 2 1) " m") "Direct link"))
              (rtos (/ area fac fac) 2 2)
              rows)
        (list (- (car add) (car rmv)) (- (cadr add) (cadr rmv)))
        h pts))

;; Widening values for one side : (w st en s1 s2)
;; the right side uses its own fields when Both sides + different chainage
(defun rp:wside-par (sg fac st0 / sx st en)
  (setq sx (if (and (< sg 0) (= (rp:val "wside") "2") (= (rp:val "wdiff") "1")) "2" "")
        st (* fac (- (rp:num (strcat "wst" sx)) st0))
        en (* fac (- (rp:num (strcat "wen" sx)) st0)))
  (list (* fac (rp:num (strcat "wwid" sx))) st en
        (- st (* fac (rp:num (strcat "wtin" sx))))
        (+ en (* fac (rp:num (strcat "wtout" sx))))
        (* fac (rp:num (strcat "wrad" sx)))))

;; Keep the fillet radius inside the tapers and the full-width length
(defun rp:wrf (rf w st en s1 s2 fac sg / rfmax dl)
  (if (> rf 0.0)
    (progn
      (setq rfmax 1e99)
      (foreach tl (list (- st s1) (- s2 en))
        (setq dl    (atan w tl)
              rfmax (min rfmax (/ (min (* 0.5 (sqrt (+ (* tl tl) (* w w)))) (* 0.5 (- en st)))
                                  (/ (sin (* 0.5 dl)) (cos (* 0.5 dl)))))))
      (if (> rf rfmax)
        (progn
          (princ (strcat "\nFillet radius reduced to " (rtos (/ rfmax fac) 2 1) " m on the "
                         (if (> sg 0) "left" "right") " side so it fits inside the tapers."))
          rfmax)
        rf))
    rf))

(defun rp:widen-run (e / data fac obj len st0 hw bgap bwid blen two curve rf0 rf pr bad
                       sides recs old id bl br res surf iv elev th wgaps)
  (setq data (rp:xget e)
        *rp:etype* (rp:etype data)
        fac  (atof (rp:xv "FAC" data)))
  (if (<= fac 0.0) (setq fac 1.0))
  (setq obj      (vlax-ename->vla-object e)
        len      (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
        *rp:len* len
        elev     (vla-get-Elevation obj)
        st0      (atof (rp:xv "CHST" data))
        iv       (* fac (atof (rp:xv "CHINT" data)))
        hw       (* 0.5 fac (atof (rp:xv "W" data)))
        bgap     (* fac (atof (rp:xv "BGAP" data)))
        bwid     (* fac (atof (rp:xv "BWID" data)))
        blen     (* fac (atof (rp:xv "BLEN" data)))
        two      (/= (rp:xv "TWOWAY" data) "0")
        th       (* fac (rp:num "txth"))
        curve    (= (rp:val "wtype") "1")
        rf0      (and (not curve) (= (rp:val "wmatch") "0"))
        sides    (cond ((= (rp:val "wside") "0") '(1.0))
                       ((= (rp:val "wside") "1") '(-1.0))
                       (T '(1.0 -1.0)))
        *rp:hatches* nil)
  (if (<= blen 0.0) (setq blen (* 2.0 fac)))
  ;; check every side before drawing anything
  (foreach sg sides
    (setq pr (rp:wside-par sg fac st0))
    (if (and (not bad) (or (< (nth 3 pr) -1e-6) (> (nth 4 pr) (+ len 1e-6))))
      (setq bad (list sg pr))))
  (cond
    (bad
     (alert (strcat "The " (if (> (car bad) 0) "LEFT" "RIGHT")
                    " side widening with its tapers runs outside the road.\n\n"
                    "Road : " (rp:chfmt st0) " to " (rp:chfmt (+ st0 (/ len fac))) "\n"
                    "Widening incl. tapers : " (rp:chfmt (+ st0 (/ (nth 3 (cadr bad)) fac))) " to "
                    (rp:chfmt (+ st0 (/ (nth 4 (cadr bad)) fac))) "\n\n"
                    "The start chainage is where the FULL width starts;\n"
                    "the taper in is added before it.")))
    (T
     (setq *rp:conc* (rp:road-conc obj))
     (setq old (vlax-ldata-get obj "ROADPRO_WIDEN")
           id  (strcat "W" (itoa (1+ (length old))))
           bl  (rp:pairget (rp:xv "BL" data))
           br  (rp:pairget (rp:xv "BR" data)))
     (foreach sg sides
       (setq pr  (rp:wside-par sg fac st0)
             rf  (rp:wrf (if rf0 (nth 5 pr) 0.0) (nth 0 pr) (nth 1 pr) (nth 2 pr) (nth 3 pr) (nth 4 pr) fac sg)
             res (rp:widen-side obj id sg hw (nth 0 pr) (nth 3 pr) (nth 1 pr) (nth 2 pr) (nth 4 pr)
                                curve rf fac th elev st0 iv
                                (and (rp:on "wbar")
                                     (rp:edge-on data sg))
                                bgap bwid blen two))
       (setq wgaps (append wgaps
                           (list (list "E" sg (nth 3 pr) (nth 4 pr))
                                 (list "W" sg (rp:wprofile (nth 3 pr) (nth 1 pr) (nth 2 pr) (nth 4 pr) (nth 0 pr) curve rf fac))
                                 (list "A" sg (nth 1 pr) (nth 2 pr)))))
       (setq recs (cons (car res) recs)
             surf (cons (caddr res) surf))
       (if (> sg 0)
         (setq bl (list (+ (car bl) (car (cadr res))) (+ (cadr bl) (cadr (cadr res)))))
         (setq br (list (+ (car br) (car (cadr res))) (+ (cadr br) (cadr (cadr res)))))))
     ;; draw order, stored data
     (if *rp:hatches* (rp:toback *rp:hatches*))
     (if surf (rp:toback surf))
     (vlax-ldata-put obj "ROADPRO_WIDEN" (append old (reverse recs)))
     (rp:ops-add obj "W" nil)
     (vlax-ldata-put obj "ROADPRO_MKGAP" (append (vlax-ldata-get obj "ROADPRO_MKGAP") wgaps))
     (setq data (vl-remove-if '(lambda (x) (member (car x) '("BL" "BR"))) data))
     (rp:xput e (append data (list (cons "BL" (rp:pair bl)) (cons "BR" (rp:pair br)))))
     (rp:refresh e)
     (foreach r (reverse recs)
       (princ (strcat "\n  " (car r) " (" (cadr r) ") +" (caddr r) " m  CH " (nth 3 r) " - " (nth 4 r)
                      "  |  " (nth 7 r) ", " (nth 8 r) "  |  area " (nth 9 r) " m2")))
     (princ "\n  Lane widening added. Run RDR for the updated report.")))
  (princ))

;;----------------------------------------------------------------------------
;;  ROAD TAPER
;;  Widen (+) or narrow (-) the road edge on the left, right or both sides
;;  between ANY start and end chainage. The new width continues to the road
;;  end; add more tapers anywhere to change it again (they add up).
;;    Taper type  : Straight (linear)  or  Curve (reverse curve)
;;    Match point : Fillet with radius R  or  Direct link
;;  Each run rebuilds the edge, surface, barricades and labels of that side.
;;----------------------------------------------------------------------------
(setq *rp:tdcl*
 (list
  "roadtaper : dialog {"
  "  label = \"ROAD PRO  -  Road Taper\";"
  "  : text { key = \"info\"; width = 64; }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Where and how much  (Left side when different)\";"
  "      : popup_list { key = \"tside\";  label = \"Side:\";                     edit_width = 16; }"
  "      : edit_box   { key = \"tst\";    label = \"Taper start chainage (m):\"; edit_width = 8; }"
  "      : edit_box   { key = \"ten\";    label = \"Taper end chainage (m):\";   edit_width = 8; }"
  "      : edit_box   { key = \"tshift\"; label = \"Edge shift per side (m):\";  edit_width = 8; }"
  "      : text { label = \"+ = wider road     - = narrower road\"; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Right side  (Both sides only)\";"
  "      : toggle   { key = \"tdiff\";   label = \"Different chainage on right side\"; }"
  "      : edit_box { key = \"tst2\";    label = \"Taper start chainage (m):\"; edit_width = 8; }"
  "      : edit_box { key = \"ten2\";    label = \"Taper end chainage (m):\";   edit_width = 8; }"
  "      : edit_box { key = \"tshift2\"; label = \"Edge shift (m):\";           edit_width = 8; }"
  "      : edit_box { key = \"trad2\";   label = \"Fillet radius (m):\";        edit_width = 8; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Taper and match points\";"
  "      : popup_list { key = \"ttype\";  label = \"Taper type:\";  edit_width = 26; }"
  "      : popup_list { key = \"tmatch\"; label = \"Match point:\"; edit_width = 26; }"
  "      : edit_box   { key = \"trad\";   label = \"Fillet radius (m):\"; edit_width = 8; }"
  "      : toggle { key = \"tbar\"; label = \"Barricades follow the new edge\"; }"
  "      : toggle { key = \"tlab\"; label = \"Labels and match points\"; }"
  "    }"
  "  }"
  "  : text { label = \"The new width continues to the road end. Run RDT again to add more tapers anywhere.\"; }"
  "  spacer;"
  "  ok_cancel;"
  "  errtile;"
  "}"))

(defun rp:tdlg-modes (/ st both)
  (setq st   (= (get_tile "ttype") "0")
        both (= (get_tile "tside") "2"))
  (mode_tile "tmatch" (if st 0 1))
  (mode_tile "trad" (if (and st (= (get_tile "tmatch") "0")) 0 1))
  (mode_tile "tdiff" (if both 0 1))
  (foreach k '("tst2" "ten2" "tshift2")
    (mode_tile k (if (and both (= (get_tile "tdiff") "1")) 0 1)))
  (mode_tile "trad2" (if (and both (= (get_tile "tdiff") "1") st (= (get_tile "tmatch") "0")) 0 1)))

(defun rp:tdlg-accept (/ bad v v2 r2)
  (setq r2 (and (= (get_tile "tside") "2") (= (get_tile "tdiff") "1")))
  (foreach k (append '(("tst" "Taper start chainage" 1) ("ten" "Taper end chainage" 1) ("trad" "Fillet radius" 0))
                     (if r2 '(("tst2" "Right taper start chainage" 1) ("ten2" "Right taper end chainage" 1)
                              ("trad2" "Right fillet radius" 0))))
    (if (not bad)
      (progn
        (setq v (rp:dist (get_tile (car k))))
        (if (or (null v) (if (= (caddr k) 1) (< v 0.0) (<= v 0.0)))
          (setq bad k)))))
  (setq v  (rp:dist (get_tile "tshift"))
        v2 (rp:dist (get_tile "tshift2")))
  (cond
    (bad
     (set_tile "error" (strcat (cadr bad)
                               (if (= (caddr bad) 1)
                                 " must be zero or a positive number."
                                 " must be a number greater than zero.")))
     (mode_tile (car bad) 2))
    ((or (null v) (< (abs v) 0.001))
     (set_tile "error" "Edge shift must be a number, + to widen or - to narrow (not zero).")
     (mode_tile "tshift" 2))
    ((<= (rp:dist (get_tile "ten")) (rp:dist (get_tile "tst")))
     (set_tile "error" "Taper end chainage must be greater than the start chainage.")
     (mode_tile "ten" 2))
    ((and r2 (or (null v2) (< (abs v2) 0.001)))
     (set_tile "error" "Right side edge shift must be + to widen or - to narrow (not zero).")
     (mode_tile "tshift2" 2))
    ((and r2 (<= (rp:dist (get_tile "ten2")) (rp:dist (get_tile "tst2"))))
     (set_tile "error" "Right side: taper end chainage must be greater than the start chainage.")
     (mode_tile "ten2" 2))
    (T
     (foreach k *rp:tkeys* (rp:set k (get_tile k)))
     (done_dialog 1))))

(defun rp:tdialog (info / fn f id res)
  (setq fn (vl-filename-mktemp "roadtaper.dcl"))
  (if (setq f (open fn "w"))
    (progn
      (foreach l *rp:tdcl* (write-line l f))
      (close f)
      (setq id (load_dialog fn))
      (if (and id (not (minusp id)) (new_dialog "roadtaper" id))
        (progn
          (rp:fill "tside"  '("Left" "Right" "Both sides"))
          (rp:fill "ttype"  '("Straight (linear) taper" "Curve (reverse-curve) taper"))
          (rp:fill "tmatch" '("Fillet at match points" "Direct link (no fillet)"))
          (foreach k *rp:tkeys* (set_tile k (rp:val k)))
          (set_tile "info" info)
          (rp:tdlg-modes)
          (foreach k '("ttype" "tmatch" "tside" "tdiff") (action_tile k "(rp:tdlg-modes)"))
          (action_tile "accept" "(rp:tdlg-accept)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq res (if (= (start_dialog) 1) 'ok 'cancel)))
        (setq res 'fail))
      (if (and id (not (minusp id))) (unload_dialog id))
      (vl-file-delete fn))
    (setq res 'fail))
  res)

;; One-way taper profile (s o) : from 0 at the start match point to d at the end
(defun rp:tprofile (a b d curve rf fac / sg ad out s big k pts n)
  (if curve
    (progn
      (setq sg  (if (< d 0.0) -1.0 1.0)
            ad  (abs d)
            out (list (list a 0.0))
            s   (+ a (* 0.25 fac)))
      (while (< s b)
        (setq out (cons (list s (* sg (rp:rc-o (- s a) (- b a) ad))) out)
              s   (+ s (* 0.25 fac))))
      (rp:densify (reverse (cons (list b d) out)) (* 0.5 fac)))
    (progn
      (setq big (max (* 2.0 rf) fac)
            k   (list (list (- a big) 0.0) (list a 0.0) (list b d) (list (+ b big) d))
            n   (max 6 (fix (/ (* rf 0.4) (* 0.25 fac)))))
      (setq pts (append (list (car k))
                        (if (> rf 0.0)
                          (append (rp:fillet-pts (nth 0 k) (nth 1 k) (nth 2 k) rf n)
                                  (rp:fillet-pts (nth 1 k) (nth 2 k) (nth 3 k) rf n))
                          (list (nth 1 k) (nth 2 k)))))
      (while (and (cadr pts) (< (abs (cadr (cadr pts))) 1e-7)) (setq pts (cdr pts)))
      (rp:densify pts (* 0.5 fac)))))

;; Profile value that HOLDS the end value after the last point
(defun rp:prof-hold (pts s)
  (cond ((<= s (car (car pts))) (cadr (car pts)))
        ((>= s (car (last pts))) (cadr (last pts)))
        (T (rp:prof-o pts s))))

(defun rp:taper-profs (recs sg fac / out)
  (foreach r recs
    (if (= (nth 2 r) sg)
      (setq out (cons (rp:tprofile (nth 3 r) (nth 4 r) (nth 5 r) (= (nth 6 r) 1) (nth 7 r) fac) out))))
  (reverse out))

;; Edge offset from the CL on one side at station s (all tapers of that side)
(defun rp:soff (profs hw s / t0)
  (setq t0 hw)
  (foreach p profs (setq t0 (+ t0 (rp:prof-hold p s))))
  t0)

(defun rp:tstations (profs s0 len fac / s lst out prev)
  (setq s s0)
  (while (< s len) (setq lst (cons s lst) s (+ s fac)))
  (setq lst (cons len lst))
  (foreach p profs
    (foreach q p (if (and (>= (car q) s0) (<= (car q) len)) (setq lst (cons (car q) lst)))))
  (foreach x (vl-sort lst '<)
    (if (or (null prev) (> (- x prev) 1e-6)) (setq out (cons x out) prev x)))
  (reverse out))

(defun rp:since (mark / e lst)
  (setq e (if mark (entnext mark) (entnext)))
  (while e (setq lst (cons e lst) e (entnext e)))
  (reverse lst))

(defun rp:order-ss (enames opt / ss)
  (setq ss (ssadd))
  (foreach en enames (ssadd en ss))
  (if (> (sslength ss) 0) (command "_.DRAWORDER" ss "" opt)))

;; Break object e between points p1 and p2. The points are snapped onto e,
;; OSNAP is off, and BREAK is never left waiting for the user.
(defun rp:break (e p1 p2 / om q1 q2)
  (if (and e (entget e) p1 p2)
    (progn
      (setq q1 (vlax-curve-getClosestPointTo e (list (car p1) (cadr p1) (if (caddr p1) (caddr p1) 0.0)))
            q2 (vlax-curve-getClosestPointTo e (list (car p2) (cadr p2) (if (caddr p2) (caddr p2) 0.0))))
      (if (and q1 q2 (> (distance (list (car q1) (cadr q1)) (list (car q2) (cadr q2))) 1e-6))
        (progn
          (setq om (getvar "OSMODE"))
          (setvar "OSMODE" 0)
          (command "_.BREAK" (list e (trans q1 0 1)) "_F" (trans q1 0 1) (trans q2 0 1))
          (while (> (getvar "CMDACTIVE") 0) (command))
          (setvar "OSMODE" om)
          T)))))

;; Shorten the original road edge on one side, from station s to its end
(defun rp:break-edge (cl sg hw s fac elev / p ss i e cp best bl l om)
  (setq p  (rp:offpt cl s (* sg hw))
        ss (ssget "_X" '((0 . "LWPOLYLINE") (8 . "ROAD-EDGE")))
        i  0
        bl 0.0)
  (if ss
    (repeat (sslength ss)
      (setq e (ssname ss i) i (1+ i)
            cp (vlax-curve-getClosestPointTo e (list (car p) (cadr p) elev)))
      (if (and cp (< (distance (list (car cp) (cadr cp)) p) (* 0.002 fac)))
        (progn
          (setq l (vlax-curve-getDistAtParam e (vlax-curve-getEndParam e)))
          (if (> l bl) (setq best e bl l))))))
  (if best
    (progn
      (setq om (getvar "OSMODE"))
      (setvar "OSMODE" 0)
      (rp:break best (list (car p) (cadr p) elev) (vlax-curve-getEndPoint best))
      (setvar "OSMODE" om)
      T)
    (progn (princ "\nNote: original road edge not found on this side - it was left as it is.") nil)))

;; Wipeout over a narrowed area, returns its area
(defun rp:wipe (pts elev / pl ar w)
  (setq pl (rp:poly pts "ROAD-SURFACE" elev)
        ar (vla-get-Area pl))
  (command "_.WIPEOUT" "_P" (vlax-vla-object->ename pl) "_Y")
  (setq w (entlast))
  (if (and w (= (cdr (assoc 0 (entget w))) "WIPEOUT"))
    (vla-put-Layer (vlax-ename->vla-object w) "ROAD-SURFACE"))
  ar)

;; Rebuild everything a taper changes on one side. Returns (d-red d-white add-area cut-area)
(defun rp:taper-rebuild (cl sg hw fac len elev blen bgap bwid barq labq st0 th all
                         / sd recs profs s0 e en nr nw brk mark stl offs grp grps prev cur o k
                           newp oldp bnd h addA cutA rmv bstart rel add p q pp mid f ang rot ip mt
                           new ty ly wl bh sh oth)
  (setq sd    (if (> sg 0) "L" "R")
        recs  (vl-remove-if-not '(lambda (r) (= (nth 2 r) sg)) all)
        profs (rp:taper-profs all sg fac)
        s0    (apply 'min (mapcar '(lambda (x) (car (car x))) profs))
        nr 0 nw 0 addA 0.0 cutA 0.0 add (list 0 0))
  ;; 1. remove what earlier tapers drew on this side
  (foreach hd (vlax-ldata-get cl (strcat "ROADPRO_TMAN_" sd))
    (if (and (setq en (handent hd)) (entget en))
      (progn
        (if (= (cdr (assoc 0 (entget en))) "HATCH")
          (cond ((= (cdr (assoc 8 (entget en))) "ROAD-BARRIER-RED") (setq nr (1+ nr)))
                ((= (cdr (assoc 8 (entget en))) "ROAD-BARRIER-WHITE") (setq nw (1+ nw)))))
        (entdel en))))
  ;; 2. shorten the original edge (only further back than before)
  (setq brk (vlax-ldata-get cl (strcat "ROADPRO_TBRK_" sd)))
  (if (or (null brk) (< s0 (- brk 1e-6)))
    (progn
      (rp:break-edge cl sg hw s0 fac elev)
      (vlax-ldata-put cl (strcat "ROADPRO_TBRK_" sd) s0)))
  (setq mark (entlast))
  ;; 3. new edge from the first taper to the road end
  (setq stl  (rp:tstations profs s0 len fac)
        offs (mapcar '(lambda (x) (list x (rp:soff profs hw x))) stl))
  (rp:mkpl (mapcar '(lambda (x) (list (rp:offpt cl (car x) (* sg (cadr x))) 0.0)) offs) "ROAD-EDGE" elev nil)
  ;; 4. surface : added (hatch) and removed (wipeout) areas
  (setq cur 0)
  (foreach x offs
    (setq o (- (cadr x) hw)
          k (cond ((> o (* 0.001 fac)) 1) ((< o (* -0.001 fac)) -1) (T 0)))
    (cond
      ((and (/= k 0) (= k cur)) (setq grp (cons x grp)))
      (T
       (if grp (setq grps (cons (list cur (reverse (cons x grp))) grps)))
       (setq grp (if (/= k 0) (if prev (list x prev) (list x)) nil)
             cur k)))
    (setq prev x))
  (if grp (setq grps (cons (list cur (reverse grp)) grps)))
  (foreach g grps
    (if (>= (length (cadr g)) 2)
      (progn
        (setq newp (mapcar '(lambda (x) (rp:offpt cl (car x) (* sg (cadr x)))) (cadr g))
              oldp (reverse (mapcar '(lambda (x) (rp:offpt cl (car x) (* sg hw))) (cadr g))))
        (if (> (car g) 0)
          (progn
            (setq bnd (rp:poly (append newp oldp) "ROAD-SURFACE" elev)
                  h   (rp:newhatch "SOLID" nil elev))
            (vla-put-Layer h "ROAD-SURFACE")
            (vla-AppendOuterLoop h (rp:objarr (list bnd)))
            (vla-Evaluate h)
            (vl-catch-all-apply 'vla-put-EntityTransparency (list h "50"))
            (setq addA (+ addA (vla-get-Area h)))
            (vla-Delete bnd))
          (setq cutA (+ cutA (rp:wipe (append newp oldp) elev)))))))
  ;; 5. barricades follow the new edge
  (if barq
    (progn
      (setq rmv    (rp:wbar-remove cl sg hw s0 len blen)
            bstart (vlax-ldata-get cl (strcat "ROADPRO_TBAR_" sd))
            nr     (+ nr (car rmv))
            nw     (+ nw (cadr rmv)))
      (if (caddr rmv)
        (setq bstart (if bstart
                       (min bstart (- (caddr rmv) (* 0.5 blen)))
                       (- (caddr rmv) (* 0.5 blen)))))
      (if bstart
        (progn
          (setq bstart (max 0.0 bstart)
                rel    (mapcar '(lambda (x) (list (car x) (- (cadr x) hw))) offs))
          (vlax-ldata-put cl (strcat "ROADPRO_TBAR_" sd) bstart)
          (setq add (rp:barrier-prof cl rel sg hw bgap bwid bstart len blen
                                     (min blen (* 0.5 fac)) elev
                                     (fix (+ 0.5 (/ bstart blen)))))))))
  ;; 6. labels and match points
  (if labq
    (foreach r recs
      (setq p (rp:tprofile (nth 3 r) (nth 4 r) (nth 5 r) (= (nth 6 r) 1) (nth 7 r) fac))
      (foreach q (list (list (car (car p)) "TS") (list (car (last p)) "TE"))
        (setq o  (rp:soff profs hw (car q))
              pp (rp:offpt cl (car q) (* sg o)))
        (vla-put-Layer (vla-AddCircle *rp:spc* (rp:p3 pp elev) (* 0.3 fac)) "ROAD-WIDENING")
        (rp:sidetext cl (car q) (strcat (cadr q) " " (rp:chfmt (+ st0 (/ (car q) fac))))
                     (* sg (+ o (* 0.8 fac))) (* 0.8 th) "ROAD-WIDENING" elev))
      ;; radius marks : both fillets, or both arcs of the reverse curve
      (if (= (nth 6 r) 1)
        (foreach sc (list (+ (nth 3 r) (* 0.25 (- (nth 4 r) (nth 3 r))))
                          (+ (nth 3 r) (* 0.75 (- (nth 4 r) (nth 3 r)))))
          (rp:rmark cl sc (rp:soff profs hw sc) sg
                    (/ (+ (* (- (nth 4 r) (nth 3 r)) (- (nth 4 r) (nth 3 r))) (* (nth 5 r) (nth 5 r)))
                       (* 4.0 (abs (nth 5 r))))
                    fac th elev))
        (if (> (nth 7 r) 0.0)
          (foreach sc (list (nth 3 r) (nth 4 r))
            (rp:rmark cl sc (rp:soff profs hw sc) sg (nth 7 r) fac th elev))))
      (setq mid (* 0.5 (+ (nth 3 r) (nth 4 r)))
            f   (rp:frame cl mid)
            ang (angle '(0.0 0.0) (caddr f))
            rot (if (and (> ang (* 0.5 pi)) (<= ang (* 1.5 pi))) (+ ang pi) ang)
            ip  (rp:offpt cl mid (* sg (+ (rp:soff profs hw mid) bgap bwid fac (* 3.0 th))))
            mt  (vla-AddMText *rp:spc* (rp:p3 ip elev) 0.0
                  (strcat "ROAD TAPER " (car r) "  EDGE " (if (> (nth 5 r) 0) "+" "")
                          (rtos (/ (nth 5 r) fac) 2 2) " m"
                          "\\PCH " (rp:chfmt (+ st0 (/ (nth 3 r) fac))) " - "
                          (rp:chfmt (+ st0 (/ (nth 4 r) fac)))
                          "   L = " (rtos (/ (- (nth 4 r) (nth 3 r)) fac) 2 1) " m"
                          "\\P"
                          (if (= (nth 6 r) 1)
                            (strcat "CURVE TAPER (REVERSE CURVE)  R "
                                    (rtos (/ (/ (+ (* (- (nth 4 r) (nth 3 r)) (- (nth 4 r) (nth 3 r)))
                                                   (* (nth 5 r) (nth 5 r)))
                                                (* 4.0 (abs (nth 5 r))))
                                             fac) 2 1) " m")
                            (strcat "STRAIGHT TAPER 1:" (rtos (/ (- (nth 4 r) (nth 3 r)) (abs (nth 5 r))) 2 1)
                                    (if (> (nth 7 r) 0.0)
                                      (strcat "  -  FILLET R=" (rtos (/ (nth 7 r) fac) 2 1) " m")
                                      "  -  DIRECT LINK")))
                          "\\PROAD WIDTH " (nth 8 r) " m  >  " (nth 9 r) " m")))
      (vla-put-Height mt (* 0.8 th))
      (vla-put-AttachmentPoint mt acAttachmentPointMiddleCenter)
      (vla-put-InsertionPoint mt (rp:p3 ip elev))
      (vla-put-Rotation mt rot)
      (vla-put-Layer mt "ROAD-WIDENING")))
  ;; 7. draw order and bookkeeping
  (setq new (rp:since mark))
  (foreach en new
    (setq ty (cdr (assoc 0 (entget en))) ly (cdr (assoc 8 (entget en))))
    (cond ((= ty "WIPEOUT") (setq wl (cons en wl)))
          ((and (= ty "HATCH") (= ly "ROAD-SURFACE")) (setq sh (cons en sh)))
          ((= ty "HATCH") (setq bh (cons en bh)))
          (T (setq oth (cons en oth)))))
  (if wl  (rp:order-ss (reverse wl) "_F"))
  (if bh  (rp:order-ss (reverse bh) "_F"))
  (if oth (rp:order-ss (reverse oth) "_F"))
  (if sh  (rp:order-ss (reverse sh) "_B"))
  (vlax-ldata-put cl (strcat "ROADPRO_TMAN_" sd)
                  (mapcar '(lambda (x) (cdr (assoc 5 (entget x)))) new))
  (list (- (car add) nr) (- (cadr add) nw) addA cutA))

;; Taper values for one side : (a b d)
;; the right side uses its own fields when Both sides + different chainage
(defun rp:tside-par (sg fac st0 / sx)
  (setq sx (if (and (< sg 0) (= (rp:val "tside") "2") (= (rp:val "tdiff") "1")) "2" ""))
  (list (* fac (- (rp:num (strcat "tst" sx)) st0))
        (* fac (- (rp:num (strcat "ten" sx)) st0))
        (* fac (rp:num (strcat "tshift" sx)))
        (* fac (rp:num (strcat "trad" sx)))))

;; Road width (both sides) at station x for a list of taper records
(defun rp:twidth (recs x hw fac)
  (+ (rp:soff (rp:taper-profs recs 1.0 fac) hw x) (rp:soff (rp:taper-profs recs -1.0 fac) hw x)))

(defun rp:taper-run (e / data fac obj len st0 hw bgap bwid blen elev th curve rf0 rf pr a b d
                       hyp dl rfmax old n id sides newrecs all bad bads s profs bl br res sd)
  (setq data (rp:xget e)
        *rp:etype* (rp:etype data)
        fac  (atof (rp:xv "FAC" data)))
  (if (<= fac 0.0) (setq fac 1.0))
  (setq obj      (vlax-ename->vla-object e)
        len      (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
        *rp:len* len
        elev     (vla-get-Elevation obj)
        st0      (atof (rp:xv "CHST" data))
        hw       (* 0.5 fac (atof (rp:xv "W" data)))
        bgap     (* fac (atof (rp:xv "BGAP" data)))
        bwid     (* fac (atof (rp:xv "BWID" data)))
        blen     (* fac (atof (rp:xv "BLEN" data)))
        th       (* fac (rp:num "txth"))
        curve    (= (rp:val "ttype") "1")
        rf0      (and (not curve) (= (rp:val "tmatch") "0"))
        sides    (cond ((= (rp:val "tside") "0") '(1.0))
                       ((= (rp:val "tside") "1") '(-1.0))
                       (T '(1.0 -1.0)))
        *rp:hatches* nil)
  (if (<= blen 0.0) (setq blen (* 2.0 fac)))
  ;; check every side before drawing anything
  (foreach sg sides
    (setq pr (rp:tside-par sg fac st0))
    (if (and (not bads)
             (or (< (car pr) -1e-6) (> (cadr pr) (+ len 1e-6)) (< (abs (caddr pr)) 1e-9)))
      (setq bads (list sg pr))))
  (cond
    ((vlax-curve-isClosed obj)
     (alert "Road tapers are not available on closed (loop) roads."))
    (bads
     (alert (strcat "The " (if (> (car bads) 0) "LEFT" "RIGHT") " side taper is not valid.\n\n"
                    "Road : " (rp:chfmt st0) " to " (rp:chfmt (+ st0 (/ len fac))) "\n"
                    "Taper : " (rp:chfmt (+ st0 (/ (car (cadr bads)) fac))) " to "
                    (rp:chfmt (+ st0 (/ (cadr (cadr bads)) fac)))
                    "\n\nThe taper must lie inside the road and the edge shift cannot be zero.")))
    (T
     (setq old (vlax-ldata-get obj "ROADPRO_TAPERS")
           n   (1+ (if (vlax-ldata-get obj "ROADPRO_TCOUNT") (vlax-ldata-get obj "ROADPRO_TCOUNT") 0))
           id  (strcat "T" (itoa n)))
     (foreach sg sides
       (setq pr (rp:tside-par sg fac st0)
             a  (car pr) b (cadr pr) d (caddr pr)
             rf (if rf0 (cadddr pr) 0.0))
       ;; keep the fillets inside the taper and the road
       (if (> rf 0.0)
         (progn
           (setq hyp   (sqrt (+ (* (- b a) (- b a)) (* d d)))
                 dl    (atan (abs d) (- b a))
                 rfmax (/ (min (* 0.5 hyp) (max (* 0.01 fac) a) (max (* 0.01 fac) (- len b)))
                          (/ (sin (* 0.5 dl)) (cos (* 0.5 dl)))))
           (if (> rf rfmax)
             (progn
               (princ (strcat "\nFillet radius reduced to " (rtos (/ rfmax fac) 2 1) " m on the "
                              (if (> sg 0) "left" "right") " side so it fits inside the taper."))
               (setq rf rfmax)))))
       (setq newrecs (cons (list (strcat id "-" (if (> sg 0) "L" "R")) (if (> sg 0) "Left" "Right")
                                 sg a b d (if curve 1 0) rf)
                           newrecs)))
     (setq newrecs (reverse newrecs)
           all     (append old newrecs))
     ;; the edge must stay clear of the centre line
     (foreach sg sides
       (setq profs (rp:taper-profs all sg fac) s 0.0)
       (while (and (not bad) (<= s len))
         (if (< (rp:soff profs hw s) (* 0.3 fac)) (setq bad s))
         (setq s (+ s fac))))
     (if bad
       (alert (strcat "The road edge would reach the centre line near CH "
                      (rp:chfmt (+ st0 (/ bad fac))) ".\n\nUse a smaller narrowing."))
       (progn
         (setq newrecs (mapcar '(lambda (r)
                                  (append r (list (rtos (/ (rp:twidth all (max 0.0 (- (nth 3 r) fac)) hw fac) fac) 2 2)
                                                  (rtos (/ (rp:twidth all (min len (+ (nth 4 r) fac)) hw fac) fac) 2 2))))
                               newrecs)
               all     (append old newrecs))
         (vlax-ldata-put obj "ROADPRO_TAPERS" all)
         (vlax-ldata-put obj "ROADPRO_TCOUNT" n)
         (rp:ops-add obj "T" nil)
         (setq bl (rp:pairget (rp:xv "BL" data))
               br (rp:pairget (rp:xv "BR" data)))
         (foreach sg sides
           (setq sd  (if (> sg 0) "L" "R")
                 res (rp:taper-rebuild obj sg hw fac len elev blen bgap bwid
                                       (and (rp:on "tbar") (rp:edge-on data sg))
                                       (rp:on "tlab") st0 th all))
           (vlax-ldata-put obj (strcat "ROADPRO_TAREA_" sd) (list (caddr res) (cadddr res)))
           (if (> sg 0)
             (setq bl (list (+ (car bl) (car res)) (+ (cadr bl) (cadr res))))
             (setq br (list (+ (car br) (car res)) (+ (cadr br) (cadr res))))))
         (setq data (vl-remove-if '(lambda (x) (member (car x) '("BL" "BR"))) data))
         (rp:xput e (append data (list (cons "BL" (rp:pair bl)) (cons "BR" (rp:pair br)))))
         (rp:refresh e)
         (foreach r newrecs
           (princ (strcat "\n  Road taper " (car r) " (" (cadr r) ") : CH "
                          (rp:chfmt (+ st0 (/ (nth 3 r) fac))) " - " (rp:chfmt (+ st0 (/ (nth 4 r) fac)))
                          ",  edge " (if (> (nth 5 r) 0) "+" "") (rtos (/ (nth 5 r) fac) 2 2)
                          " m,  road width " (nth 8 r) " m > " (nth 9 r) " m")))
         (princ "\n  Run RDR for the updated report.")))))
  (princ))

;; Report rows for tapers : (rows setting-out-rows net-area) or nil
(defun rp:taper-report (obj fac hw st0 iv len / recs rows sto sg profs p s0 s1 s kp o pp ar addT cutT)
  (setq recs (vlax-ldata-get obj "ROADPRO_TAPERS"))
  (if recs
    (progn
      (setq rows (list '("#" "ROAD TAPERS")))
      (foreach r recs
        (setq rows (append rows
                     (list (list (strcat (car r) " - " (cadr r) " side")
                                 (strcat "edge " (if (> (nth 5 r) 0) "+" "") (rtos (/ (nth 5 r) fac) 2 2)
                                         " m,  CH " (rp:chfmt (+ st0 (/ (nth 3 r) fac))) " - "
                                         (rp:chfmt (+ st0 (/ (nth 4 r) fac)))))
                           (list (strcat "   " (car r) " taper / match")
                                 (strcat (if (= (nth 6 r) 1) "Curve (reverse curve)" "Straight") ",  "
                                         (if (= (nth 6 r) 1) "tangent"
                                           (if (> (nth 7 r) 0.0)
                                             (strcat "fillet R " (rtos (/ (nth 7 r) fac) 2 1) " m")
                                             "direct link"))))
                           (list (strcat "   " (car r) " road width") (strcat (nth 8 r) " m  >  " (nth 9 r) " m"))))))
      (foreach r recs
        (setq sg    (nth 2 r)
              profs (rp:taper-profs recs sg fac)
              p     (rp:tprofile (nth 3 r) (nth 4 r) (nth 5 r) (= (nth 6 r) 1) (nth 7 r) fac)
              s0    (car (car p))
              s1    (car (last p))
              kp    (list (list s0 "TS") (list s1 "TE")))
        (if (> iv 0.0)
          (progn
            (setq s (- (* iv (fix (+ 1.0 (/ (+ s0 (* st0 fac)) iv)))) (* st0 fac)))
            (while (< s s1)
              (if (> s s0) (setq kp (cons (list s "CH") kp)))
              (setq s (+ s iv)))))
        (foreach q (vl-sort kp '(lambda (a b) (< (car a) (car b))))
          (setq o   (rp:soff profs hw (car q))
                pp  (rp:offpt obj (car q) (* sg o))
                sto (cons (list (car r) (cadr q) (rp:chfmt (+ st0 (/ (car q) fac)))
                                (rtos (/ (* sg o) fac) 2 3)
                                (rtos (/ (car pp) fac) 2 3) (rtos (/ (cadr pp) fac) 2 3))
                          sto))))
      (setq addT 0.0 cutT 0.0)
      (foreach sd '("L" "R")
        (if (setq ar (vlax-ldata-get obj (strcat "ROADPRO_TAREA_" sd)))
          (setq addT (+ addT (car ar)) cutT (+ cutT (cadr ar)))))
      (setq rows (append rows
                   (list (list "Taper area added / removed"
                               (strcat (rtos (/ addT fac fac) 2 2) " / " (rtos (/ cutT fac fac) 2 2) " m2"))
                         (list "Road width at road end"
                               (strcat (rtos (/ (+ (rp:soff (rp:taper-profs recs 1.0 fac) hw len)
                                                   (rp:soff (rp:taper-profs recs -1.0 fac) hw len))
                                                fac) 2 3) " m")))))
      (list rows (reverse sto) (/ (- addT cutT) fac fac)))))

;;----------------------------------------------------------------------------
;;  ROAD JUNCTION / TIE-IN
;;  Join a new (branch) road to an existing RoadPro road. The branch is built
;;  with the normal RoadPro settings, then the junction is formed:
;;    - main road edge opened between the kerb returns
;;    - kerb-return arcs (corner radius) left and right, radius marked
;;    - corner and mouth surface, barricades cleared from the mouth and
;;      placed around the corners, STOP / GIVE WAY on the branch
;;    - junction label and setting-out (TC / IP / CT of each corner)
;;----------------------------------------------------------------------------
(setq *rp:jdcl*
 (list
  "roadjunc : dialog {"
  "  label = \"ROAD PRO  -  Road Junction / Tie-in / Roundabout\";"
  "  : text { key = \"info\"; width = 96; }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Joining road (branch)\";"
  "      : edit_box   { key = \"jname\"; label = \"Branch road name / ID:\"; edit_width = 14; }"
  "      : edit_box   { key = \"jwid\";  label = \"Branch road width (m):\"; edit_width = 8; }"
  "      : popup_list { key = \"jmode\"; label = \"Branch centre line:\";    edit_width = 28; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Junction type and design standard\";"
  "      : popup_list { key = \"jtype\";  label = \"Junction type:\";               edit_width = 36; }"
  "      : popup_list { key = \"jstd\";   label = \"Design standard:\";             edit_width = 36; }"
  "      : popup_list { key = \"jcls\";   label = \"Road class / design vehicle:\"; edit_width = 36; }"
  "      : toggle     { key = \"jsight\"; label = \"Sight triangles (ISD) at the junction\"; }"
  "    }"
  "  }"
  "  : text { key = \"jinfo\"; width = 96; }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Priority junction (kerb returns)\";"
  "      : edit_box   { key = \"jrad\";    label = \"Corner (kerb return) radius (m):\"; edit_width = 8; }"
  "      : popup_list { key = \"jctl\";    label = \"Control on the branch:\";           edit_width = 18; }"
  "      : toggle     { key = \"jmark\";   label = \"Road markings in the turning area\"; }"
  "      : toggle     { key = \"jbar\";    label = \"Edge treatment around the corners\"; }"
  "      : popup_list { key = \"jcorner\"; label = \"Corner treatment:\"; edit_width = 22; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Roundabout at the junction (FHWA)\";"
  "      : popup_list { key = \"rbstd\"; label = \"Standard:\"; edit_width = 50; }"
  "      : edit_box   { key = \"rbr\";   label = \"Inscribed radius R = ICD / 2 (m):\"; edit_width = 8; }"
  "      : button     { key = \"rbset\"; label = \"More roundabout settings...\"; }"
  "    }"
  "  }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Main road auxiliary lane at the junction\";"
  "      : toggle   { key = \"jaux\";   label = \"Add auxiliary lane (two taper lines)\"; }"
  "      : edit_box { key = \"jauxw\";  label = \"Lane width (m):\";              edit_width = 6; }"
  "      : edit_box { key = \"jlong\";  label = \"Approach taper, long (m):\";    edit_width = 6; }"
  "      : edit_box { key = \"jshort\"; label = \"Departure taper, short (m):\";  edit_width = 6; }"
  "      : edit_box { key = \"jstore\"; label = \"Storage length (m):\";          edit_width = 6; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Island on the branch\";"
  "      : popup_list { key = \"jisl\";  label = \"Island:\";           edit_width = 26; }"
  "      : edit_box   { key = \"jislw\"; label = \"Island width (m):\";  edit_width = 6; }"
  "      : edit_box   { key = \"jisll\"; label = \"Island length (m):\"; edit_width = 6; }"
  "    }"
  "  }"
  "  : text { label = \"Start the branch centre line ON the main road centre line and draw outward.\"; }"
  "  : text { label = \"Barricades, signs, chainage and sidewalks of the branch use your RDP settings.\"; }"
  "  : text { label = \"Developed by https://www.exceltokml.com/\"; alignment = right; }"
  "  ok_cancel;"
  "  errtile;"
  "}"))

(defun rp:jdlg-modes (/ rb)
  (setq rb (= (get_tile "jtype") "1"))
  (mode_tile "jcorner" (if (= (get_tile "jbar") "1") 0 1))
  (foreach k '("jauxw" "jlong" "jshort" "jstore")
    (mode_tile k (if (and (not rb) (= (get_tile "jaux") "1")) 0 1)))
  (foreach k '("jislw" "jisll")
    (mode_tile k (if (and (not rb) (/= (get_tile "jisl") "0")) 0 1)))
  (foreach k '("jaux" "jisl" "jrad" "jctl" "jmark" "jsight" "jstd" "jcls")
    (mode_tile k (if rb 1 0)))
  (if (not rb) (mode_tile "jcls" (if (= (get_tile "jstd") "1") 0 1)))
  (foreach k '("rbstd" "rbr" "rbset") (mode_tile k (if rb 0 1))))

(defun rp:jdlg-accept (/ bad v rb)
  (setq rb (= (get_tile "jtype") "1"))
  (foreach k (append '(("jwid" "Branch road width") ("jrad" "Corner radius") ("jauxw" "Auxiliary lane width")
                       ("jlong" "Long taper") ("jshort" "Short taper") ("jstore" "Storage length")
                       ("jislw" "Island width") ("jisll" "Island length"))
                     (if rb '(("rbr" "Inscribed radius"))))
    (if (not bad)
      (progn
        (setq v (rp:dist (get_tile (car k))))
        (if (or (null v) (<= v 0.0)) (setq bad k)))))
  (cond
    (bad
     (set_tile "error" (strcat (cadr bad) " must be a number greater than zero."))
     (mode_tile (car bad) 2))
    ((= (vl-string-trim " " (get_tile "jname")) "")
     (set_tile "error" "Enter a name for the branch road.")
     (mode_tile "jname" 2))
    ((and rb (<= (rp:dist (get_tile "rbr")) (+ (* 0.5 (rp:dist (get_tile "jwid"))) 1.0)))
     (set_tile "error" "The inscribed radius must be more than half the branch width + 1 m.")
     (mode_tile "rbr" 2))
    (T
     ;; a new roundabout standard brings all its values (widths, radii, islands)
     (if (and rb (/= (get_tile "rbstd") (rp:val "rbstd"))) (rp:rb-env (atoi (get_tile "rbstd"))))
     (foreach k *rp:jkeys* (rp:set k (get_tile k)))
     (done_dialog 1))))

(defun rp:jdialog (info / fn f id res)
  (setq fn (vl-filename-mktemp "roadjunc.dcl"))
  (if (setq f (open fn "w"))
    (progn
      (foreach l *rp:jdcl* (write-line l f))
      (close f)
      (setq id (load_dialog fn))
      (if (and id (not (minusp id)) (new_dialog "roadjunc" id))
        (progn
          (rp:fill "jmode"   '("Draw new (from main road CL)" "Select existing Line/Pline/Arc"))
          (rp:fill "jctl"    '("STOP sign" "GIVE WAY sign" "No sign"))
          (rp:fill "jisl"    '("No island" "Splitter island - kerbed" "Splitter island - painted"))
          (rp:fill "jcorner" '("Same as main road" "Barricades (red / white)" "Traffic cones" "Kerb stone"))
          (rp:fill "jtype"   '("Priority junction (kerb returns)" "Roundabout (FHWA standard)"))
          (rp:fill "jstd"    '("Manual (values in this dialog)" "Saudi Arabia - SHC 301 / MOMRA (AASHTO)"))
          (rp:fill "jcls"    *rp:sa-cls*)
          (rp:fill "rbstd"   (mapcar 'car *rp:rbstds*))
          (foreach k *rp:jkeys* (set_tile k (rp:val k)))
          (set_tile "info" info)
          (rp:jstd-apply nil)
          (rp:jdlg-modes)
          (foreach k '("jaux" "jisl" "jbar" "jtype") (action_tile k "(rp:jdlg-modes)"))
          (action_tile "jstd" "(rp:jstd-apply T) (rp:jdlg-modes)")
          (action_tile "jcls" "(rp:jstd-apply T)")
          (action_tile "rbstd" "(rp:jrb-std)")
          (action_tile "rbset" "(rp:jrb-more)")
          (action_tile "accept" "(rp:jdlg-accept)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq res (if (= (start_dialog) 1) 'ok 'cancel)))
        (setq res 'fail))
      (if (and id (not (minusp id))) (unload_dialog id))
      (vl-file-delete fn))
    (setq res 'fail))
  res)

;; ---- geometry helpers ----
(defun rp:p2 (p) (list (car p) (cadr p)))

(defun rp:inters (o1 o2 mode / v sa l out)
  (setq v (vl-catch-all-apply 'vla-IntersectWith (list o1 o2 mode)))
  (if (not (vl-catch-all-error-p v))
    (progn
      (setq sa (vlax-variant-value v))
      (if (and (= (type sa) 'SAFEARRAY) (>= (vlax-safearray-get-u-bound sa 1) 0))
        (progn
          (setq l (vlax-safearray->list sa))
          (while l (setq out (cons (list (car l) (cadr l) (caddr l)) out) l (cdddr l)))))))
  (reverse out))

(defun rp:nearest (pts p / best bd d)
  (setq bd 1e99)
  (foreach q pts (if (< (setq d (distance (rp:p2 q) (rp:p2 p))) bd) (setq best q bd d)))
  best)

(defun rp:cpt (obj p / z)
  (setq z (caddr (vlax-curve-getStartPoint obj)))
  (vlax-curve-getClosestPointTo obj (list (car p) (cadr p) z)))

;; signed lateral offset of point c from a curve (+ = left of its direction)
(defun rp:lat (obj c / cp dv)
  (setq cp (rp:cpt obj c)
        dv (vlax-curve-getFirstDeriv obj (vlax-curve-getParamAtPoint obj cp)))
  (- (* (car dv) (- (cadr c) (cadr cp))) (* (cadr dv) (- (car c) (car cp)))))

(defun rp:unitv (v / l) (setq l (distance '(0.0 0.0) (rp:p2 v))) (if (< l 1e-12) '(1.0 0.0) (list (/ (car v) l) (/ (cadr v) l))))

(defun rp:edge-near (p fac excl / ss i e d best bd)
  (setq ss (ssget "_X" '((0 . "LWPOLYLINE") (8 . "ROAD-EDGE"))) i 0 bd 1e99)
  (if ss
    (repeat (sslength ss)
      (setq e (ssname ss i) i (1+ i))
      (if (not (member e excl))
        (progn
          (setq d (distance (rp:p2 (rp:cpt e p)) (rp:p2 p)))
          (if (< d bd) (setq best e bd d))))))
  (if (and best (< bd (* 5.0 fac))) best))

;; Remove barricade units beside a road : side sg, true lateral distance between
;; lo and hi, centre station between sA and sB. Returns (red white)
(defun rp:jbar-band (obj sg lo hi sA sB / ss i e o mn mx c cp d lat nr nw nc nk lay)
  (setq nr 0 nw 0 nc 0 nk 0
        ss (ssget "_X" '((8 . "ROAD-BARRIER-RED,ROAD-BARRIER-WHITE,ROAD-BARRIER-OUTLINE,ROAD-CONE,ROAD-CONE-BAND,ROAD-KERB")))
        i  0)
  (if ss
    (repeat (sslength ss)
      (setq e (ssname ss i) i (1+ i))
      (if (entget e)
        (progn
          (setq o (vlax-ename->vla-object e))
          (vla-GetBoundingBox o 'mn 'mx)
          (setq mn  (vlax-safearray->list mn)
                mx  (vlax-safearray->list mx)
                c   (list (* 0.5 (+ (car mn) (car mx))) (* 0.5 (+ (cadr mn) (cadr mx))))
                cp  (rp:cpt obj c)
                d   (vlax-curve-getDistAtPoint obj cp)
                lat (* (if (> (rp:lat obj c) 0.0) 1.0 -1.0) (distance c (rp:p2 cp))))
          (if (and d (>= d sA) (<= d sB) (> (* sg lat) lo) (< (* sg lat) hi))
            (progn
              (setq lay (vla-get-Layer o))
              (if (= (vla-get-ObjectName o) "AcDbHatch")
                (cond ((= lay "ROAD-BARRIER-RED") (setq nr (1+ nr)))
                      ((= lay "ROAD-BARRIER-WHITE") (setq nw (1+ nw)))
                      ((= lay "ROAD-CONE") (setq nc (1+ nc)))
                      ((= lay "ROAD-KERB") (setq nk (1+ nk)))))
              (vla-Delete o)))))))
  (list nr nw nc nk))

;; Remove barricade units near the junction; counts per owner road and side
(defun rp:jbar-remove (pts rad mobj bobj / ss i e o mn mx c hit lay own key cnt a)
  (setq cnt (list (list "ML" 0 0) (list "MR" 0 0) (list "BL" 0 0) (list "BR" 0 0))
        ss  (ssget "_X" '((8 . "ROAD-BARRIER-RED,ROAD-BARRIER-WHITE,ROAD-BARRIER-OUTLINE,ROAD-CONE,ROAD-CONE-BAND,ROAD-KERB")))
        i   0)
  (if ss
    (repeat (sslength ss)
      (setq e (ssname ss i) o (vlax-ename->vla-object e) i (1+ i) hit nil)
      (vla-GetBoundingBox o 'mn 'mx)
      (setq mn (vlax-safearray->list mn) mx (vlax-safearray->list mx)
            c  (list (* 0.5 (+ (car mn) (car mx))) (* 0.5 (+ (cadr mn) (cadr mx)))))
      (foreach q pts (if (and (not hit) (< (distance c (rp:p2 q)) rad)) (setq hit T)))
      (if hit
        (progn
          (setq lay (vla-get-Layer o))
          (if (/= lay "ROAD-BARRIER-OUTLINE")
            (progn
              (setq own (if (< (distance c (rp:p2 (rp:cpt mobj c))) (distance c (rp:p2 (rp:cpt bobj c)))) mobj bobj)
                    key (strcat (if (eq own mobj) "M" "B") (if (> (rp:lat own c) 0.0) "L" "R"))
                    a   (assoc key cnt))
              (setq cnt (subst (if (= lay "ROAD-BARRIER-RED")
                                 (list key (1+ (cadr a)) (caddr a))
                                 (list key (cadr a) (1+ (caddr a))))
                               a cnt))))
          (vla-Delete o)))))
  cnt)

(defun rp:jsurf (pts elev / bnd h ar)
  (setq bnd (rp:poly pts "ROAD-SURFACE" elev)
        ar  (vla-get-Area bnd))
  (if (> ar 1e-6)
    (progn
      (setq h (rp:newhatch "SOLID" nil elev))
      (vla-put-Layer h "ROAD-SURFACE")
      (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-AppendOuterLoop (list h (rp:objarr (list bnd)))))
        (progn (vla-Delete h) (setq h nil ar 0.0))
        (progn
          (vla-Evaluate h)
          (vl-catch-all-apply 'vla-put-EntityTransparency (list h "50"))
          (rp:surf-color h)))))
  (vla-Delete bnd)
  (list h ar))

;; White road-marking polygon
(defun rp:jmk (pts elev)
  (rp:solidfill (rp:poly pts "ROAD-MARKING" elev) nil "ROAD-MARKING-FILL" elev))

;; Point from a base, x along direction d, y to the left of d
(defun rp:lmap (base d x y)
  (list (+ (car base) (* x (car d)) (* -1.0 y (cadr d)))
        (+ (cadr base) (* x (cadr d)) (* y (car d)))))

;; Radius mark at the middle of a kerb-return arc
(defun rp:jrmark (arc ip rr fac th elev / mid u pt pm tx)
  (setq mid (nth (/ (length arc) 2) arc)
        u   (rp:unitv (list (- (car mid) (car ip)) (- (cadr mid) (cadr ip))))
        pm  (rp:pt+ mid u (* 1.2 fac))
        pt  (rp:pt+ mid u (+ (* 1.2 fac) (* 1.4 th))))
  (rp:mkwpl (list (list pm 0.0 0.0) (list (rp:towards mid pm (* 0.5 th)) (* 0.25 th) 0.0) (list mid 0.0 0.0))
            "ROAD-JUNCTION" elev)
  (setq tx (rp:text (strcat "R=" (rtos (/ rr fac) 2 2)) pt (* 0.8 th) "ROAD-JUNCTION" elev)))

;; Junction rows for the report of the MAIN road : (rows setting-out) or nil
;; Junction and roundabout rows for the report of the MAIN road :
;; (rows setting-out) or nil
(defun rp:junc-report (obj / recs rb rows sto)
  (setq recs (vlax-ldata-get obj "ROADPRO_JUNC")
        rb   (vlax-ldata-get obj "ROADPRO_RBT"))
  (if (or recs rb)
    (progn
      (if recs
        (progn
          (setq rows (list '("#" "JUNCTIONS / TIE-INS")))
          (foreach r recs
            (setq rows (append rows
                         (vl-remove nil
                           (list (list (strcat (car r) " - " (cadr r))
                                       (strcat "at CH " (nth 2 r) " (" (nth 3 r) " side)"))
                                 (list (strcat "   " (car r) " angle / corner R")
                                       (strcat (nth 4 r) "  /  R " (nth 5 r) " m"))
                                 (list (strcat "   " (car r) " control") (nth 6 r))
                                 (if (nth 8 r) (list (strcat "   " (car r) " road markings") (nth 8 r)))
                                 (if (nth 9 r) (list (strcat "   " (car r) " design standard") (nth 9 r)))))))
            (foreach q (nth 7 r) (setq sto (cons q sto))))))
      (if rb
        (progn
          (setq rows (append rows (list '("#" "ROUNDABOUTS (FHWA ROUNDABOUTS: AN INFORMATIONAL GUIDE)"))))
          (foreach r rb
            (setq rows (append rows
                         (list (list (strcat (car r) " - standard") (nth 1 r))
                               (list (strcat "   " (car r) " centre") (strcat "CH " (nth 2 r) ",  " (nth 10 r) " legs"))
                               (list (strcat "   " (car r) " ICD / circulatory / apron")
                                     (strcat (nth 3 r) " / " (nth 4 r) " / " (nth 5 r) " m"))
                               (list (strcat "   " (car r) " entry / exit radius") (strcat "R " (nth 6 r) " / R " (nth 7 r) " m"))
                               (list (strcat "   " (car r) " lanes / design speed")
                                     (strcat (nth 9 r) " circulating, " (nth 8 r) " km/h, lane line " (nth 18 r)))
                               (list (strcat "   " (car r) " splitter islands")
                                     (strcat (nth 11 r) " m long, " (nth 12 r) " m wide at the circle, pedestrian crossings " (nth 17 r)))
                               (list (strcat "   " (car r) " central island") (nth 13 r))
                               (list (strcat "   " (car r) " signs / corners") (strcat (itoa (nth 15 r)) " signs, " (nth 16 r))))))
            (foreach q (nth 14 r) (setq sto (cons q sto))))))
      (list rows (reverse sto)))))

(defun rp:junction-run (me / mdata fac mobj mlen st0 hwm bgap bwid blen elev th br bobj bpt dJ fj sg
                          mside medge xs saved res hwb blen2 rr bd e1 e2 corners k be bep ip ub tm
                          oth dl tl arc t1 t2 c ar pts surfs nm bdata bfac bl br2 cnt cntm cntb add
                          ang jid recs rows jct lbl mid fb rot mt t2d sd ok
                          mbar bbar s1 glo ghi sb st2 bge pg pb path key
                          mkl q1 q2 u12 sl f dv lm tx shp jty jadd jrem jsum
                          hwe waux mh lng sht sto wst wen wtin wtout auxp iv iw il i0 ilo h hl hr pts2 nn d de
                          jsv isd jstx mhas spdm s0 pa jh)
  (setq mdata (rp:xget me)
        *rp:etype* (rp:etype mdata)
        fac   (atof (rp:xv "FAC" mdata)))
  (if (<= fac 0.0) (setq fac 1.0))
  (setq mobj (vlax-ename->vla-object me)
        *rp:conc* (rp:road-conc mobj)
        mlen (vlax-curve-getDistAtParam mobj (vlax-curve-getEndParam mobj))
        st0  (atof (rp:xv "CHST" mdata))
        hwm  (* 0.5 fac (atof (rp:xv "W" mdata)))
        bgap (* fac (atof (rp:xv "BGAP" mdata)))
        bwid (* fac (atof (rp:xv "BWID" mdata)))
        blen (* fac (atof (rp:xv "BLEN" mdata)))
        elev (vla-get-Elevation mobj)
        th   (* fac (rp:num "txth"))
        hwb  (* 0.5 fac (rp:num "jwid"))
        rr   (* fac (rp:num "jrad")))
  (if (<= blen 0.0) (setq blen (* 2.0 fac)))
  ;; 1. branch centre line
  (setq saved (rp:val "mode"))
  (rp:set "mode" (rp:val "jmode"))
  (princ "\nBranch centre line : start ON the main road centre line and go outward.")
  (setq br (rp:get-centreline))
  (rp:set "mode" saved)
  (cond
    ((null br) (princ "\nNo branch centre line - junction cancelled."))
    ((eq br me) (alert "The branch cannot be the main road itself."))
    (T
     ;; start of the branch must be the end nearest the main road
     (if (> (distance (rp:p2 (vlax-curve-getStartPoint br)) (rp:p2 (rp:cpt mobj (vlax-curve-getStartPoint br))))
            (distance (rp:p2 (vlax-curve-getEndPoint br)) (rp:p2 (rp:cpt mobj (vlax-curve-getEndPoint br)))))
       (command "_.REVERSE" br ""))
     (setq bobj (vlax-ename->vla-object br)
           bpt  (vlax-curve-getStartPoint br))
     ;; v3.6 replay : put back the piece of centre line inside the junction mouth
     (if (and *rp:replay* (setq jh (vlax-ldata-get bobj "RPJHEAD"))
              (< (distance (rp:p2 (last (car jh))) (rp:p2 (vlax-curve-getStartPoint br))) (* 0.01 fac)))
       (progn (rp:pl-prepend bobj jh) (setq bpt (vlax-curve-getStartPoint br))))
     ;; replay after the main road moved : bring the branch start back onto it
     (if (and *rp:replay* (rp:extend-start br mobj (+ hwm (* 2.0 fac))))
       (setq bpt (vlax-curve-getStartPoint br)))
     (cond
       ((> (distance (rp:p2 bpt) (rp:p2 (rp:cpt mobj bpt))) (+ hwm (* 2.0 fac)))
        (alert "The branch centre line must start on (or very near) the main road.\n\nJunction cancelled."))
       ;; v3.5 : roundabout at the junction
       ((= (rp:val "jtype") "1")
        (rp:rbt-run me (rp:sta mobj bpt) (list (list br (rp:val "jname") (rp:num "jwid")))))
       (T
        ;; 2. which side of the main road, and the junction station
        (setq *rp:len* mlen
              dJ   (vlax-curve-getDistAtPoint mobj (rp:cpt mobj bpt))
              fj   (rp:frame mobj dJ)
              ub   (rp:unitv (vlax-curve-getFirstDeriv br (vlax-curve-getStartParam br)))
              sg   (if (> (+ (* (car ub) (car (cadr fj))) (* (cadr ub) (cadr (cadr fj)))) 0.0) 1.0 -1.0)
              mside (if (> sg 0) "Left" "Right")
              ang  (rp:acos (abs (+ (* (car ub) (car (caddr fj))) (* (cadr ub) (cadr (caddr fj)))))))
        ;; 2b. auxiliary lane on the main road : long taper on the approach side, short on the departure
        (setq hwe hwm waux 0.0 auxp nil
              iv  (* fac (atof (rp:xv "CHINT" mdata))))
        (if (rp:on "jaux")
          (progn
            ;; v3.6 : full lane width over the whole junction (both kerb returns + 2 m)
            (setq waux (* fac (rp:num "jauxw"))
                  mh   (+ (/ hwb (max 0.2 (sin ang)))
                          (* (+ hwm waux) (abs (/ (cos ang) (max 0.2 (sin ang)))))
                          (* rr (/ (cos (* 0.5 ang)) (max 0.1 (sin (* 0.5 ang)))))
                          (* 2.0 fac))
                  lng  (* fac (rp:num "jlong"))
                  sht  (* fac (rp:num "jshort"))
                  sto  (* fac (rp:num "jstore")))
            ;; keep right : on the RIGHT side traffic comes from the lower chainage
            (if (< sg 0)
              (setq wst (- dJ mh sto) wen (+ dJ mh) wtin lng wtout sht)
              (setq wst (- dJ mh) wen (+ dJ mh sto) wtin sht wtout lng))
            (if (or (< (- wst wtin) 0.0) (> (+ wen wtout) mlen))
              (progn
                (princ "\nAuxiliary lane skipped : with its tapers it would run outside the main road.")
                (setq waux 0.0))
              (progn
                (setq k (rp:widen-side mobj (strcat "J" (itoa (1+ (length (vlax-ldata-get mobj "ROADPRO_JUNC")))) "-AUX")
                                       sg hwm waux (- wst wtin) wst wen (+ wen wtout) nil
                                       (rp:wrf (* 30.0 fac) waux wst wen (- wst wtin) (+ wen wtout) fac sg)
                                       fac th elev st0 iv
                                       (rp:edge-on mdata sg)
                                       bgap bwid blen (rp:on "twoway")))
                (vlax-ldata-put mobj "ROADPRO_WIDEN" (append (vlax-ldata-get mobj "ROADPRO_WIDEN") (list (car k))))
                (setq key   (if (> sg 0) "BL" "BR")
                      cntm  (rp:pairget (rp:xv key mdata))
                      mdata (append (vl-remove-if '(lambda (x) (= (car x) key)) mdata)
                                    (list (cons key (rp:pair (list (+ (car cntm) (car (cadr k)))
                                                                   (+ (cadr cntm) (cadr (cadr k))))))))
                      surfs (list (caddr k))
                      auxp  (cadddr k)
                      hwe   (+ hwm waux))
                (rp:xput me mdata)
                (setq *rp:len* mlen)))))
        (setq medge (rp:edge-near (list (car (rp:offpt mobj dJ (* sg hwe))) (cadr (rp:offpt mobj dJ (* sg hwe))) elev) fac nil))
        (cond
          ((null medge) (alert "The main road edge was not found at the junction.\n\nJunction cancelled."))
          (T
           ;; 3. cut the branch centre line back to the main road edge
           (setq xs (rp:inters bobj (vlax-ename->vla-object medge) acExtendNone))
           (if xs
             (progn
               (setq k (rp:nearest xs bpt))
               (if (> (distance (rp:p2 k) (rp:p2 bpt)) (* 0.01 fac))
                 (progn
                   (setvar "OSMODE" 0)
                   (rp:break br bpt k)))))
           ;; 3b. v3.6 : the kerb returns are worked out BEFORE the branch is built,
           ;;     from temporary offsets of the branch centre line, so the branch can
           ;;     start where the returns end : nothing of the branch (surface,
           ;;     barricades, corridor, markings) is drawn inside the junction mouth.
           (setq *rp:len* (vlax-curve-getDistAtParam bobj (vlax-curve-getEndParam bobj))
                 blen2 *rp:len*
                 corners nil res nil s0 0.0)
           (foreach sd (list 1.0 -1.0)
             (if (setq k (rp:offset bobj (* sd hwb)))
               (progn
                 (setq be  (rp:longest k)
                       bep (vlax-curve-getStartPoint be)
                       ip  (rp:nearest (rp:inters be (vlax-ename->vla-object medge) acExtendThisEntity) bep))
                 (if ip
                   (progn
                     (setq oth nil
                           ub  (rp:unitv (vlax-curve-getFirstDeriv be (vlax-curve-getStartParam be)))
                           tl  (vlax-curve-getDistAtParam be (vlax-curve-getEndParam be)))
                     (setq corners (cons (list be (rp:p2 bep) ip ub tl) corners))))
                 (foreach x k (if (not (member x (mapcar 'car corners))) (vla-Delete x))))))
           (setq corners (reverse corners))
           (if (/= (length corners) 2)
             (progn
               (foreach cr corners (vla-Delete (car cr)))
               (alert "The kerb returns could not be formed (branch edges do not meet the main road edge).\n\nJunction cancelled."))
             (progn
               ;; kerb-return arcs (T1 on the main edge > T2 on the branch edge)
               (foreach cr corners
                 (setq ip  (caddr cr) ub (cadddr cr)
                       oth (caddr (if (eq cr (car corners)) (cadr corners) (car corners)))
                       tm  (rp:unitv (vlax-curve-getFirstDeriv medge
                                       (vlax-curve-getParamAtPoint medge (rp:cpt medge ip)))))
                 (if (< (+ (* (car tm) (- (car ip) (car oth))) (* (cadr tm) (- (cadr ip) (cadr oth)))) 0.0)
                   (setq tm (list (- (car tm)) (- (cadr tm)))))
                 (setq dl (rp:acos (+ (* (- (car tm)) (car ub)) (* (- (cadr tm)) (cadr ub))))
                       tl (* rr (/ (sin (* 0.5 dl)) (cos (* 0.5 dl))))
                       c  rr)
                 (if (> tl (* 0.6 (nth 4 cr)))
                   (setq c (/ (* 0.6 (nth 4 cr)) (/ (sin (* 0.5 dl)) (cos (* 0.5 dl))))))
                 (setq arc (rp:fillet-pts (rp:pt+ (rp:p2 ip) tm (* 4.0 c)) (rp:p2 ip)
                                          (rp:pt+ (rp:p2 ip) ub (* 4.0 c)) c 24))
                 (setq res (cons (list nil (cadr cr) (rp:p2 ip) arc c) res)
                       s0  (max s0 (rp:sta bobj (append (last arc) (list elev))))))
               (setq res (reverse res))
               (foreach cr corners (vla-Delete (car cr)))
               ;; 3c. the branch centre line starts where the returns end ; the piece in
               ;;     the mouth is kept as a plain centre line (and remembered for rebuilds)
               (setq s0 (min s0 (* 0.8 blen2)))
               (if (> s0 (* 0.01 fac))
                 (progn
                   (setq k (rp:pl-head bobj s0))
                   (vlax-ldata-put bobj "RPJHEAD" k)
                   (setq h (rp:mkpl (mapcar 'list (car k) (cadr k)) "ROAD-CL" elev nil))
                   (rp:props h "ROAD-CL" (rp:cl-ltype) (/ fac (getvar "LTSCALE")))
                   (setvar "OSMODE" 0)
                   (rp:break br (vlax-curve-getStartPoint br) (vlax-curve-getPointAtDist br s0))))
               ;; 4. build the branch with the RDP settings
               (setq saved (mapcar '(lambda (x) (cons x (rp:val x)))
                                   '("rname" "width" "endst" "report" "xsec" "chst" "ccarr" "clmode" "cmed" "keep")))
               (rp:set "ccarr" "0")
               (rp:set "clmode" "0")
               (rp:set "cmed" "0")
               (rp:set "keep" "0")
               (rp:set "rname" (rp:val "jname"))
               (rp:set "width" (rp:val "jwid"))
               (rp:set "endst" "3")
               (rp:set "report" "0")
               (rp:set "xsec" "0")
               (rp:set "chst" (rtos (/ s0 fac) 2 3))
               (setq *rp:presetcl* br)
               (setq ok (vl-catch-all-apply 'rp:run nil))
               (setq *rp:presetcl* nil)
               (foreach x saved (rp:set (car x) (cdr x)))
               (cond
                 ((or (vl-catch-all-error-p ok) (null (rp:xget br)))
                  (alert "The branch road could not be built.\n\nJunction cancelled."))
                 (T
                  (setq bdata (rp:xget br)
                        *rp:conc* (rp:road-conc mobj)
                        *rp:hatches* nil
                        blen2 (vlax-curve-getDistAtParam br (vlax-curve-getEndParam br))
                        *rp:len* blen2)
                  ;; 7. open the main road edge between the two returns (main edge points
                  ;;    kept first for the mouth surface)
                  (setvar "OSMODE" 0)
                  (setq t1  (rp:cpt medge (append (car (nth 3 (car res))) (list elev)))
                        t2  (rp:cpt medge (append (car (nth 3 (cadr res))) (list elev)))
                        pts (rp:edge-pts medge (vlax-curve-getDistAtPoint medge t2) (vlax-curve-getDistAtPoint medge t1) fac))
                  (rp:break medge t1 t2)
                  ;; 8. branch edge pieces between the end of each return and the branch start
                  (foreach cr res
                    (setq arc (nth 3 cr)
                          sb  (if (> (rp:lat bobj (cadr cr)) 0.0) 1.0 -1.0)
                          pb  (rp:offpt bobj 0.0 (* sb hwb)))
                    (if (> (distance (last arc) pb) (* 0.01 fac))
                      (rp:line (last arc) pb "ROAD-EDGE" elev))
                    (rp:mkpl (mapcar '(lambda (q) (list q 0.0)) arc) "ROAD-EDGE" elev nil))
                  ;; 9. ONE surface for the whole mouth : main edge > return > branch start
                  ;;    > return > main edge. It only touches the main road and branch
                  ;;    surfaces, so the hatches never overlap.
                  (setq *rp:len* blen2
                        pa  (rp:offpt bobj 0.0 (* (if (> (rp:lat bobj (cadr (car res))) 0.0) 1.0 -1.0) hwb))
                        pb  (rp:offpt bobj 0.0 (* (if (> (rp:lat bobj (cadr (cadr res))) 0.0) 1.0 -1.0) hwb))
                        k   (append (nth 3 (car res))
                                    (if (> (distance (last (nth 3 (car res))) pa) (* 0.01 fac)) (list pa))
                                    (if (> (distance (last (nth 3 (cadr res))) pb) (* 0.01 fac)) (list pb))
                                    (reverse (nth 3 (cadr res)))
                                    (cdr (reverse (cdr (reverse pts))))))
                  (setq surfs (cons (car (rp:jsurf (rp:dedupe k (* 0.001 fac)) elev)) surfs))
                  ;; paved shoulder of the main road : not inside the mouth
                  (setq *rp:len* mlen)
                  (rp:shld-cut mobj sg (rp:sta mobj t2) (rp:sta mobj t1) fac elev)
                  ;; 10. barricades : remove exactly the units that touch the junction
                  ;;     (whole units on the main road and on the branch), then lay ONE
                  ;;     continuous run per corner : main edge > kerb return > branch edge
                  (setq cnt  (list (list "ML" 0 0) (list "MR" 0 0) (list "BL" 0 0) (list "BR" 0 0))
                        add  (list 0 0)
                        mbar (rp:edge-on mdata sg)
                        jty  (if (= (rp:val "jcorner") "0") (rp:etype mdata)
                               (itoa (1- (atoi (rp:val "jcorner")))))
                        *rp:etype* (rp:etype mdata)
                        s1   (mapcar '(lambda (cr) (vlax-curve-getDistAtPoint mobj (rp:cpt mobj (car (nth 3 cr))))) res)
                        glo  (max 0.0 (* blen (fix (/ (apply 'min s1) blen))))
                        ghi  (min mlen (* blen (fix (+ 0.999999 (/ (apply 'max s1) blen))))))
                  (setq jadd (list 0 0.0) jrem nil)
                  (setq k (rp:jbar-band mobj sg hwe (+ hwe bgap bwid (* 0.5 fac)) glo ghi)
                        jrem (list (list "M" (caddr k) (cadddr k)))
                        cnt (subst (cons (if (> sg 0) "ML" "MR") k) (assoc (if (> sg 0) "ML" "MR") cnt) cnt))
                  (foreach cr res
                    (setq arc  (nth 3 cr)
                          sb   (if (> (rp:lat bobj (cadr cr)) 0.0) 1.0 -1.0)
                          bbar (rp:edge-on bdata sb)
                          st2  (vlax-curve-getDistAtPoint bobj (rp:cpt bobj (last arc)))
                          bge  (min blen2 (* blen (fix (+ 0.999999 (/ st2 blen))))))
                    (setq k   (rp:jbar-band bobj sb hwb (+ hwb bgap bwid (* 0.5 fac)) (- blen) bge)
                          key (if (> sb 0) "BL" "BR")
                          jrem (cons (list key (caddr k) (cadddr k)) jrem)
                          cnt (subst (list key (+ (cadr (assoc key cnt)) (car k)) (+ (caddr (assoc key cnt)) (cadr k)))
                                     (assoc key cnt) cnt))
                    (if (rp:on "jbar")
                      (progn
                        ;; path : main edge at the end of the removed units > T1 > arc > T2 > branch edge
                        (setq *rp:len* mlen
                              pg   (if mbar
                                     (rp:offpt mobj (if (< (vlax-curve-getDistAtPoint mobj (rp:cpt mobj (car arc)))
                                                           (* 0.5 (+ glo ghi)))
                                                      glo ghi)
                                               (* sg hwe)))
                              *rp:len* blen2
                              pb   (if bbar (rp:offpt bobj bge (* sb hwb)))
                              path (append (if (and pg (> (distance pg (car arc)) (* 0.05 fac))) (list pg))
                                           arc
                                           (if (and pb (> (distance pb (last arc)) (* 0.05 fac))) (list pb)))
                              path (rp:mkpl (mapcar '(lambda (q) (list q 0.0)) path) "ROAD-JUNCTION" elev nil)
                              *rp:len* (vlax-curve-getDistAtParam path (vlax-curve-getEndParam path))
                              sd   (if (> (rp:lat path (caddr cr)) 0.0) -1.0 1.0)
                              k    (rp:edge-run path *rp:len* (* sd bgap) (* sd (+ bgap bwid)) jty blen fac elev)
                              add  (list (+ (car add) (car k)) (+ (cadr add) (cadr k)))
                              jadd (list (+ (car jadd) (caddr k)) (+ (cadr jadd) (cadddr k))))
                        (vla-Delete path)))
                    (setq *rp:len* blen2))
                  ;; 10a. splitter island on the branch
                  (setq iw 0.0 il 0.0 i0 0.0
                        *rp:len* blen2
                        sl (apply 'max (mapcar '(lambda (cr) (vlax-curve-getDistAtPoint bobj (rp:cpt bobj (last (nth 3 cr))))) res)))
                  (if (and (/= (rp:val "jisl") "0") (< (+ (* 0.3 sl) (* fac (rp:num "jisll"))) (- blen2 (* 5.0 fac))))
                    (progn
                      (setq iw (* fac (rp:num "jislw"))
                            il (* fac (rp:num "jisll"))
                            i0 (max (* 2.0 fac) (* 0.3 sl))
                            nn (max 12 (fix (/ il (* 0.25 fac))))
                            k  0 hl nil hr nil)
                      ;; half width : round nose, parallel middle, tapering tail
                      (repeat (1+ nn)
                        (setq d (* il (/ (float k) nn))
                              h (cond ((< d (* 0.5 iw))
                                       (sqrt (max 0.0 (- (* 0.25 iw iw) (* (- (* 0.5 iw) d) (- (* 0.5 iw) d))))))
                                      ((< d (* 0.6 il)) (* 0.5 iw))
                                      (T (+ (* 0.1 fac) (* (- (* 0.5 iw) (* 0.1 fac)) (/ (- il d) (* 0.4 il))))))
                              hl (cons (rp:offpt bobj (+ i0 d) h) hl)
                              hr (cons (rp:offpt bobj (+ i0 d) (- h)) hr)
                              k  (1+ k)))
                      (setq pts2 (append (reverse hl) hr))
                      (if (= (rp:val "jisl") "1")
                        (progn
                          ;; kerbed island : kerb outline + raised fill
                          (setq h (rp:poly pts2 "ROAD-ISLAND" elev))
                          (vla-put-ConstantWidth h (* 0.15 fac))
                          (rp:solidfill (rp:poly pts2 "ROAD-ISLAND" elev) nil "ROAD-KERB" elev)
                          (setq mkl (cons (strcat "kerbed splitter island " (rtos (/ iw fac) 2 2) " x " (rtos (/ il fac) 2 1) " m") mkl)))
                        (progn
                          ;; painted island : white border + diagonal hatching
                          (setq h (rp:poly pts2 "ROAD-MARKING-FILL" elev))
                          (vla-put-ConstantWidth h (* 0.15 fac))
                          (setq h (rp:newhatch "ANSI31" nil elev))
                          (vla-put-Layer h "ROAD-MARKING-FILL")
                          (setq k (rp:poly pts2 "ROAD-MARKING" elev))
                          (vla-AppendOuterLoop h (rp:objarr (list k)))
                          (vl-catch-all-apply 'vla-put-PatternScale (list h (* 0.35 fac)))
                          (vl-catch-all-apply 'vla-put-PatternAngle
                                              (list h (angle '(0.0 0.0) (caddr (rp:frame bobj (+ i0 (* 0.5 il)))))))
                          (vla-Evaluate h)
                          (vla-Delete k)
                          (setq mkl (cons (strcat "painted splitter island " (rtos (/ iw fac) 2 2) " x " (rtos (/ il fac) 2 1) " m") mkl))))
                      ;; KEEP RIGHT at the tail, facing traffic coming to the junction
                      (if (rp:on "twoway")
                        (rp:icon-keepright (rp:offpt bobj (+ i0 il (* 0.8 (* fac (rp:num "signsz")))) 0.0)
                                           (* 0.8 fac (rp:num "signsz")) elev))
                      (if (< (- hwb (* 0.5 iw)) (* 2.75 fac))
                        (princ "\nNote: lanes beside the island are narrower than 2.75 m - use a wider branch or a narrower island."))))
                  ;; 10b. road markings in the turning area
                  (setq mkl nil)
                  (if (rp:on "jmark")
                    (progn
                      ;; broken edge line across the junction mouth (main road edge continued)
                      (setq q1  (caddr (car res))
                            q2  (caddr (cadr res))
                            u12 (rp:unitv (list (- (car q2) (car q1)) (- (cadr q2) (cadr q1))))
                            k   0.0)
                      (while (< (+ k (* 0.6 fac)) (distance q1 q2))       ; L5/3 : 600 mark / 300 gap
                        (rp:jmk (list (rp:lmap q1 u12 k (* -0.06 fac)) (rp:lmap q1 u12 (+ k (* 0.6 fac)) (* -0.06 fac))
                                      (rp:lmap q1 u12 (+ k (* 0.6 fac)) (* 0.06 fac)) (rp:lmap q1 u12 k (* 0.06 fac)))
                                elev)
                        (setq k (+ k (* 0.9 fac))))
                      (setq mkl (list "broken edge line across the mouth"))
                      ;; approach lane of the branch (two-way : traffic coming to the junction)
                      (setq *rp:len* blen2
                            sl  (+ (apply 'max (mapcar '(lambda (cr) (vlax-curve-getDistAtPoint bobj (rp:cpt bobj (last (nth 3 cr))))) res))
                                   (* 1.0 fac)))
                      (if (and (rp:on "twoway") (< sl (- blen2 (* 20.0 fac))))
                        (progn
                          (setq f  (rp:frame bobj sl)
                                dv (list (- (car (caddr f))) (- (cadr (caddr f))))
                                ilo (+ (* 0.15 fac) (* 0.5 iw))
                                lm (* 0.5 (+ hwb (* 0.5 iw))))
                          (cond
                            ;; STOP : solid stop line + STOP word
                            ((= (rp:val "jctl") "0")
                             (rp:jmk (list (rp:loc f ilo 0.0) (rp:loc f (- hwb (* 0.15 fac)) 0.0)
                                           (rp:loc f (- hwb (* 0.15 fac)) (* 0.3 fac)) (rp:loc f ilo (* 0.3 fac)))
                                     elev)
                             (setq tx (rp:text "STOP" (rp:loc f lm (* 3.1 fac)) (* 1.6 fac) "ROAD-MARKING-FILL" elev))
                             (vl-catch-all-apply 'vla-put-ScaleFactor (list tx 0.4))
                             (vla-put-Rotation tx (- (angle '(0.0 0.0) dv) (* 0.5 pi)))
                             (setq mkl (cons "stop line + STOP word" mkl)))
                            ;; GIVE WAY : broken give-way line + triangle
                            ((= (rp:val "jctl") "1")
                             (foreach u0 (list 0.0 (* 0.4 fac))
                               (setq k ilo)
                               (while (< (+ k (* 0.6 fac)) hwb)
                                 (rp:jmk (list (rp:loc f k u0) (rp:loc f (+ k (* 0.6 fac)) u0)
                                               (rp:loc f (+ k (* 0.6 fac)) (+ u0 (* 0.2 fac))) (rp:loc f k (+ u0 (* 0.2 fac))))
                                         elev)
                                 (setq k (+ k (* 0.9 fac)))))
                             (rp:jmk (list (rp:loc f (- lm (* 0.625 fac)) (* 2.7 fac)) (rp:loc f (+ lm (* 0.625 fac)) (* 2.7 fac))
                                           (rp:loc f lm (* 6.45 fac)))
                                     elev)
                             (setq mkl (cons "give-way line + triangle" mkl))))
                          ;; left / right turn arrow 12 m before the line
                          (setq f  (rp:frame bobj (+ sl (* 12.0 fac)))
                                dv (list (- (car (caddr f))) (- (cadr (caddr f))))
                                q1 (rp:loc f lm 0.0))
                          (foreach shp (list '((0.0 -0.15) (2.85 -0.15) (2.85 0.15) (0.0 0.15))
                                             '((2.55 0.0) (2.85 0.0) (2.85 1.0) (3.15 1.0) (2.7 1.6) (2.25 1.0) (2.55 1.0))
                                             '((2.55 0.0) (2.85 0.0) (2.85 -1.0) (3.15 -1.0) (2.7 -1.6) (2.25 -1.0) (2.55 -1.0)))
                            (rp:jmk (mapcar '(lambda (q) (rp:lmap q1 dv (* fac (car q)) (* fac (cadr q)))) shp) elev))
                          (setq mkl (cons "left / right turn arrow" mkl))))))
                  ;; cone / kerb quantities on the main road side (cones counted, kerb in m)
                  (if (member (rp:etype mdata) '("1" "2"))
                    (progn
                      (setq k    (if (> sg 0) "EQL" "EQR")
                            cntb (atof (rp:xv k mdata))
                            cntb (if (= (rp:etype mdata) "1")
                                   (itoa (max 0 (+ (- (fix cntb) (cadr (assoc "M" jrem)))
                                                   (if (= jty "1") (car jadd) 0))))
                                   (rtos (max 0.0 (+ (- cntb (/ (* blen (caddr (assoc "M" jrem))) fac))
                                                     (if (= jty "2") (/ (cadr jadd) fac) 0.0))) 2 1))
                            mdata (append (vl-remove-if '(lambda (x) (= (car x) k)) mdata) (list (cons k cntb))))))
                  (setq jsum (strcat (cond ((= jty "1") (strcat (itoa (car jadd)) " traffic cones"))
                                           ((= jty "2") (strcat (rtos (/ (cadr jadd) fac) 2 1) " m kerb stone"))
                                           (T (strcat (itoa (+ (car add) (cadr add))) " barricade units")))
                                     " around the corners"))
                  ;; barricade counts : main road side and branch sides
                  (setq cntm (rp:pairget (rp:xv (if (> sg 0) "BL" "BR") mdata))
                        k    (assoc (if (> sg 0) "ML" "MR") cnt)
                        cntm (list (+ (- (car cntm) (cadr k)) (car add)) (+ (- (cadr cntm) (caddr k)) (cadr add))))
                  (setq mdata (vl-remove-if '(lambda (x) (= (car x) (if (> sg 0) "BL" "BR"))) mdata))
                  (rp:xput me (append mdata (list (cons (if (> sg 0) "BL" "BR") (rp:pair cntm)))))
                  (foreach sd '("BL" "BR")
                    (setq k    (assoc sd cnt)
                          cntb (rp:pairget (rp:xv sd bdata))
                          bdata (vl-remove-if '(lambda (x) (= (car x) sd)) bdata)
                          bdata (append bdata (list (cons sd (rp:pair (list (max 0 (- (car cntb) (cadr k)))
                                                                             (max 0 (- (cadr cntb) (caddr k))))))))))
                  (rp:xput br (append (vl-remove-if '(lambda (x) (= (car x) "JMAIN")) bdata)
                                      (list (cons "JMAIN" (vla-get-Handle mobj)))))
                  ;; 11. labels : radius marks + junction label
                  (setq *rp:len* blen2
                        recs (vlax-ldata-get mobj "ROADPRO_JUNC")
                        jid  (strcat "J" (itoa (1+ (length recs))))
                        jct  (cond ((= (rp:val "jctl") "0") "STOP") ((= (rp:val "jctl") "1") "GIVE WAY") (T "None")))
                  (foreach cr res (rp:jrmark (nth 3 cr) (caddr cr) (nth 4 cr) fac th elev))
                  (setq mid (min blen2 (+ (* 4.0 rr) (* 3.0 fac)))
                        fb  (rp:frame bobj mid)
                        ang (* 1.0 ang)
                        rot (angle '(0.0 0.0) (caddr fb))
                        rot (if (and (> rot (* 0.5 pi)) (<= rot (* 1.5 pi))) (+ rot pi) rot)
                        mt  (vla-AddMText *rp:spc*
                              (rp:p3 (rp:offpt bobj mid (+ hwb bgap bwid fac (* 3.0 th))) elev) 0.0
                              (strcat "JUNCTION " jid " : " (rp:val "jname") " joins " (rp:xv "NAME" mdata)
                                      "\\PAT CH " (rp:chfmt (+ st0 (/ dJ fac))) " (" mside " side)"
                                      "\\PANGLE " (vl-string-subst "\\U+00B0" "%%d" (rp:dms ang T))
                                      "   CORNER R=" (rtos (/ rr fac) 2 2) " m"
                                      "\\PCONTROL : " jct)))
                  (vla-put-Height mt (* 0.8 th))
                  (vla-put-AttachmentPoint mt acAttachmentPointMiddleCenter)
                  (vla-put-InsertionPoint mt (rp:p3 (rp:offpt bobj mid (+ hwb bgap bwid fac (* 3.0 th))) elev))
                  (vla-put-Rotation mt rot)
                  (vla-put-Layer mt "ROAD-JUNCTION")
                  ;; 11b. v3.5 design standard and sight triangles
                  (setq spdm (if (> (atof (rp:xv "SPEED" mdata)) 0.0) (atof (rp:xv "SPEED" mdata)) 50.0)
                        jsv  (rp:sa-vals (atoi (rp:val "jcls")) spdm)
                        isd  (if (rp:on "jsight") (rp:sight mobj bobj sg dJ hwe hwb fac elev spdm (nth 7 jsv)))
                        jstx (strcat (if (= (rp:val "jstd") "1")
                                       (strcat "Saudi Arabia SHC 301 / MOMRA (AASHTO based), design vehicle " (nth 8 jsv))
                                       "Manual values")
                                     (if isd (strcat ", sight triangles ISD " (rtos isd 2 0) " m") "")))
                  ;; 12. setting-out of the kerb returns, stored on the main road
                  (setq *rp:len* mlen sd 0)
                  (foreach cr res
                    (setq sd (1+ sd) arc (nth 3 cr))
                    (foreach q (list (list "TC" (car arc)) (list "IP" (caddr cr)) (list "CT" (last arc)))
                      (setq rows (cons (list (strcat jid "-" (itoa sd)) (car q)
                                             (rp:chfmt (+ st0 (/ (vlax-curve-getDistAtPoint mobj (rp:cpt mobj (cadr q))) fac)))
                                             (rtos (/ (car (cadr q)) fac) 2 3) (rtos (/ (cadr (cadr q)) fac) 2 3))
                                       rows))))
                  (vlax-ldata-put mobj "ROADPRO_JUNC"
                                  (append recs (list (list jid (rp:val "jname") (rp:chfmt (+ st0 (/ dJ fac))) mside
                                                           (rp:dms ang nil) (rtos (/ rr fac) 2 2) jct (reverse rows)
                                                           (if mkl (rp:join (reverse mkl) ", ") "none") jstx))))
                  ;; 13. draw order
                  (if *rp:hatches* (rp:toback *rp:hatches*))
                  (setq surfs (vl-remove nil surfs))
                  (if surfs (rp:toback surfs))
                  (princ (strcat "\n  Junction " jid " : " (rp:val "jname") " joins " (rp:xv "NAME" mdata)
                                 " at CH " (rp:chfmt (+ st0 (/ dJ fac))) ", " mside " side, corner R "
                                 (rtos (/ rr fac) 2 2) " m."))
                  (if (and jsum (rp:on "jbar")) (princ (strcat "\n  Corners : " jsum ".")))
                  ;; 14. road markings : gaps at the junction, then redraw if the roads have markings
                  (setq *rp:len* mlen
                        k    (vlax-ldata-get mobj "ROADPRO_MKGAP"))
                  (vlax-ldata-put mobj "ROADPRO_MKGAP"
                                  (append (list (list "M" sg (apply 'min s1) (apply 'max s1)))
                                          (if auxp (list (list "E" sg (car (car auxp)) (car (last auxp)))
                                                         (list "W" sg auxp)
                                                         (list "A" sg wst wen)))
                                          k))
                  (setq k nil sd 0.0)
                  (foreach cr res
                    (setq sb  (if (> (rp:lat bobj (cadr cr)) 0.0) 1.0 -1.0)
                          st2 (vlax-curve-getDistAtPoint bobj (rp:cpt bobj (last (nth 3 cr))))
                          sd  (max sd st2)
                          k   (cons (list "E" sb 0.0 st2) k)))
                  (vlax-ldata-put bobj "ROADPRO_MKGAP"
                                  (append (list (list "S" 1.0 0.0 (+ sd (* 30.0 fac))))
                                          (if (> iw 0.0) (list (list "C" 0.0 (- i0 (* 2.0 fac)) (+ i0 il (* 2.0 fac)))))
                                          k
                                          (mapcar '(lambda (g) (list "K" (cadr g) 0.0 (nth 3 g))) k)))
                  ;; v3.5 : corner records - sidewalks / walkways / drains wrap round the kerb returns
                  (setq mhas (rp:has-corr mobj))
                  (rp:jc-junction mobj bobj res sg dJ jid mhas fac elev)
                  (if (vlax-ldata-get mobj "ROADPRO_MKMAN") (rp:mark-run me))
                  (if (vlax-ldata-get bobj "ROADPRO_MKMAN") (rp:mark-run br))
                  (rp:refresh-corr me)
                  (rp:refresh-corr br)
                  (rp:ops-add mobj "J" (list (vla-get-Handle bobj)))
                  (rp:track me *rp:mk0*)
                  (princ "\n  Run RDR on either road for the updated report.")))))))))))
  (princ))

;;----------------------------------------------------------------------------
;;  ROAD MARKINGS
;;  White 150 mm lines : edge lines 0.30 m inside each edge (they follow road
;;  tapers), lane line on the centre line - broken 3 m / 6 m, solid on bends
;;  (10 m before and after) and on junction approaches. No lane line with a
;;  centre median. Gaps where junctions open the edge. Every run replaces the
;;  previous markings of that road and stores the paint quantities.
;;----------------------------------------------------------------------------
;; White strip between stations a and b; edge = T follows the edge (side sg)
;; Marking strip between stations a and b on side sg.
;; edge = T : 150 mm line ending "lo" inside the (tapered) edge; else between lo and hi
(defun rp:mk-strip (obj a b sg profs hw fac elev edge fl lo hi / s0 s1 n i d o1 o2 pa pb)
  (setq s0 a)
  (while (< s0 (- b 1e-6))
    (setq s1 (min b (+ s0 (* 50.0 fac)))
          n  (max 1 (fix (+ 0.999999 (/ (- s1 s0) fac))))
          i  0 pa nil pb nil)
    (repeat (1+ n)
      (setq d (+ s0 (* (- s1 s0) (/ (float i) n))))
      (if edge
        (setq o2 (- (rp:soff profs hw d) lo) o1 (- o2 (if *rp:ew* *rp:ew* (* 0.15 fac))))
        (setq o1 lo o2 hi))
      (setq pa (cons (rp:offpt obj d (* sg o1)) pa)
            pb (cons (rp:offpt obj d (* sg o2)) pb)
            i  (1+ i)))
    (rp:solidfill (rp:poly (append (reverse pa) pb) "ROAD-MARKING" elev) nil fl elev)
    (setq s0 s1)))

;; [a b] minus a list of (lo hi) gaps -> list of (a b) pieces
(defun rp:mk-ranges (a b gaps / out cur g)
  (setq cur a)
  (foreach g (vl-sort gaps '(lambda (x y) (< (car x) (car y))))
    (if (> (car g) cur) (setq out (cons (list cur (min b (car g))) out)))
    (setq cur (max cur (cadr g))))
  (if (< cur b) (setq out (cons (list cur b) out)))
  (vl-remove-if '(lambda (r) (< (- (cadr r) (car r)) 1e-6)) (reverse out)))

(defun rp:mk-inside (d ranges / hit)
  (foreach r ranges (if (and (> d (- (car r) 1e-6)) (< d (+ (cadr r) 1e-6))) (setq hit T)))
  hit)

(defun rp:mark-run (e / data fac obj len hw elev ct recs gaps curves en mark new sg rg cgaps
                      qe qc qs sh oth inset two f ang tx d de lm mg cm spdm solid warn pw pl pt ew
                      mo nl nr lw mw lo2 k)
  (setq data (rp:xget e)
        fac  (atof (rp:xv "FAC" data)))
  (if (<= fac 0.0) (setq fac 1.0))
  (setq obj      (vlax-ename->vla-object e)
        len      (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
        *rp:len* len
        hw       (* 0.5 fac (atof (rp:xv "W" data)))
        elev     (vla-get-Elevation obj)
        ct       (cond ((/= (rp:xv "CTYPE" data) "") (rp:xv "CTYPE" data))
                       ((/= (rp:xv "BC" data) "0,0") "1")
                       (T "0"))
        two      (/= (rp:xv "TWOWAY" data) "0")
        cm       (if (= (rp:xv "CMARK" data) "") (rp:val "cmark") (rp:xv "CMARK" data))
        spdm     (if (> (atof (rp:xv "SPEED" data)) 0.0) (atof (rp:xv "SPEED" data)) 50.0)
        ew       (* fac (if (> spdm 100.0) 0.15 0.12))           ; L4/1 expressway 150, L4/2 others 120 mm
        inset    (if (> (atof (rp:xv "BGAP" data)) 0.0) 0.0 (* 0.3 fac))   ; at the edge when there is a shoulder
        recs     (vlax-ldata-get obj "ROADPRO_TAPERS")
        gaps     (vlax-ldata-get obj "ROADPRO_MKGAP")
        curves   (rp:curves obj)
        mo       (* fac (atof (rp:xv "MO" data)))
        qe 0.0 qc 0.0 qs 0)
  (setq *rp:ew* ew)
  ;; remove the previous markings of this road
  (foreach hd (vlax-ldata-get obj "ROADPRO_MKMAN")
    (if (and (setq en (handent hd)) (entget en)) (entdel en)))
  (setq mark (entlast))
  ;; YELLOW edge lines, both sides, gaps at junction mouths ("M") and auxiliary lanes ("E")
  (foreach sg '(1.0 -1.0)
    (setq mg (mapcar '(lambda (g) (list (nth 2 g) (nth 3 g)))
                     (vl-remove-if-not '(lambda (g) (and (= (car g) "M") (= (cadr g) sg))) gaps)))
    (foreach rg (rp:mk-ranges 0.0 len
                  (append mg (mapcar '(lambda (g) (list (nth 2 g) (nth 3 g)))
                                     (vl-remove-if-not '(lambda (g) (and (= (car g) "E") (= (cadr g) sg))) gaps))))
      (rp:mk-strip obj (car rg) (cadr rg) sg (rp:taper-profs recs sg fac) hw fac elev T
                   "ROAD-MARKING-YELLOW" inset nil)
      (setq qe (+ qe (- (cadr rg) (car rg)))))
    ;; yellow edge line along an auxiliary lane ("W") and broken white lane line beside it ("A")
    (foreach g (vl-remove-if-not '(lambda (g) (and (= (car g) "W") (= (cadr g) sg))) gaps)
      (foreach rg (rp:mk-ranges (car (car (caddr g))) (car (last (caddr g))) mg)
        (rp:mk-strip obj (car rg) (cadr rg) sg (list (caddr g)) hw fac elev T "ROAD-MARKING-YELLOW" inset nil)
        (setq qe (+ qe (- (cadr rg) (car rg))))))
    (foreach g (vl-remove-if-not '(lambda (g) (and (= (car g) "A") (= (cadr g) sg))) gaps)
      (setq d (nth 2 g))
      (while (< d (nth 3 g))
        (setq de (min (nth 3 g) (+ d (* 1.0 fac))))                ; L5 : 1 m mark / 1 m gap
        (if (not (rp:mk-inside (* 0.5 (+ d de)) mg))
          (progn
            (rp:mk-strip obj d de sg nil hw fac elev nil "ROAD-MARKING-FILL" (- hw (* 0.06 fac)) (+ hw (* 0.06 fac)))
            (setq qc (+ qc (- de d)))))
        (setq d (+ d (* 2.0 fac))))))
  ;; WHITE centre line (none under a barricade median, gaps at islands)
  ;;   "0" standard : L1 lane line by speed, L2 warning line (7 marks) before
  ;;       bends and L2A solid through bends and on junction approaches
  ;;   "1" double continuous white   "2" single continuous L2A
  (if (and (/= ct "1") (not (member (rp:xv "MED" data) '("1" "2"))))
    (progn
      (setq cgaps (mapcar '(lambda (g) (list (nth 2 g) (nth 3 g)))
                          (vl-remove-if-not '(lambda (g) (= (car g) "C")) gaps)))
      (cond
        ((= cm "1")
         (foreach rg (rp:mk-ranges 0.0 len cgaps)
           (rp:mk-strip obj (car rg) (cadr rg) 1.0 nil hw fac elev nil "ROAD-MARKING-FILL" (+ mo (* 0.06 fac)) (+ mo (* 0.18 fac)))
           (rp:mk-strip obj (car rg) (cadr rg) -1.0 nil hw fac elev nil "ROAD-MARKING-FILL" (- (* 0.06 fac) mo) (- (* 0.18 fac) mo))
           (setq qc (+ qc (* 2.0 (- (cadr rg) (car rg)))))))
        ((= cm "2")
         (foreach rg (rp:mk-ranges 0.0 len cgaps)
           (rp:mk-strip obj (car rg) (cadr rg) 1.0 nil hw fac elev nil "ROAD-MARKING-FILL" (+ mo (* -0.06 fac)) (+ mo (* 0.06 fac)))
           (setq qc (+ qc (- (cadr rg) (car rg))))))
        (T
         ;; solid L2A parts : bends of 10 deg or more and junction approaches ("S")
         (setq solid nil warn nil
               pw (* fac (+ (car (rp:l2 spdm)) (cadr (rp:l2 spdm))))
               pl (* fac (+ (car (rp:l1 spdm)) (cadr (rp:l1 spdm)))))
         (foreach c curves
           (if (>= (nth 3 c) (/ pi 18.0))
             (setq solid (cons (list (car c) (cadr c)) solid)
                   warn  (cons (list (max 0.0 (- (car c) (* 7.0 pw))) (car c))
                               (cons (list (cadr c) (min len (+ (cadr c) (* 7.0 pw)))) warn)))))
         (foreach g gaps (if (= (car g) "S") (setq solid (cons (list (max 0.0 (nth 2 g)) (min len (nth 3 g))) solid))))
         (setq solid (rp:mk-ranges 0.0 len (append cgaps (rp:mk-ranges 0.0 len solid)))
               solid (rp:mk-ranges 0.0 len (append cgaps (rp:mk-ranges 0.0 len solid))))
         (foreach rg solid
           (rp:mk-strip obj (car rg) (cadr rg) 1.0 nil hw fac elev nil "ROAD-MARKING-FILL" (+ mo (* -0.06 fac)) (+ mo (* 0.06 fac)))
           (setq qc (+ qc (- (cadr rg) (car rg)))))
         ;; broken parts : L2 pattern in the warning zones, L1 elsewhere
         (setq d 0.0)
         (while (< d len)
           (setq pt (if (rp:mk-inside d warn) (rp:l2 spdm) (rp:l1 spdm))
                 de (min len (+ d (* fac (car pt)))))
           (if (and (not (rp:mk-inside d solid)) (not (rp:mk-inside de solid))
                    (not (rp:mk-inside (* 0.5 (+ d de)) cgaps)) (> (- de d) (* 0.5 fac)))
             (progn
               (rp:mk-strip obj d de 1.0 nil hw fac elev nil "ROAD-MARKING-FILL" (+ mo (* -0.06 fac)) (+ mo (* 0.06 fac)))
               (setq qc (+ qc (- de d)))))
           (setq d (+ d (* fac (+ (car pt) (cadr pt))))))))))
  ;; v3.4 : broken lane lines between lanes of the same direction, yellow
  ;; lines along the median
  (setq *rp:mkcg* (mapcar '(lambda (g) (list (nth 2 g) (nth 3 g))) (vl-remove-if-not '(lambda (g) (= (car g) "C")) gaps)))
  (setq nl (atoi (rp:xv "NL" data)) nr (atoi (rp:xv "NR" data))
        lw (* fac (atof (rp:xv "LW" data))) mw (* fac (atof (rp:xv "MW" data))))
  (if (and (> nl 0) (> lw 0.0))
    (progn
      (setq lo2 nil k 1)
      (repeat (1- nl) (setq lo2 (cons (+ mo (* 0.5 mw) (* k lw)) lo2) k (1+ k)))
      (setq k 1)
      (repeat (1- nr) (setq lo2 (cons (- mo (* 0.5 mw) (* k lw)) lo2) k (1+ k)))
      (foreach o lo2 (setq qc (+ qc (rp:mk-broken obj len o spdm fac elev))))))
  (if (and (member (rp:xv "MED" data) '("1" "2")) (> mw 0.0))
    (foreach o (list (+ mo (* 0.5 mw) (* 0.3 fac)) (- mo (* 0.5 mw) (* 0.3 fac)))
      (foreach rg (rp:mk-ranges 0.0 len *rp:mkcg*)
        (rp:mk-strip obj (car rg) (cadr rg) 1.0 nil hw fac elev nil "ROAD-MARKING-YELLOW" (- o (* 0.5 ew)) (+ o (* 0.5 ew)))
        (setq qe (+ qe (- (cadr rg) (car rg)))))))
  ;; SLOW before every bend of 10 deg or more, in each approach lane
  (if (rp:on "slow")
    (foreach c curves
      (if (>= (nth 3 c) (/ pi 18.0))
        (foreach dr (if two '(1 -1) '(1))
          (setq d  (if (= dr 1) (- (car c) (* 25.0 fac)) (+ (cadr c) (* 25.0 fac)))
                lm (* 0.5 hw (if (= dr 1) -1.0 1.0)))
          (if (and (> d (* 2.0 fac)) (< d (- len (* 2.0 fac))))
            (progn
              (setq f   (rp:frame obj d)
                    ang (angle '(0.0 0.0) (caddr f))
                    ang (if (= dr 1) ang (+ ang pi))
                    tx  (rp:text "SLOW" (rp:loc f lm 0.0) (* 1.6 fac) "ROAD-MARKING-FILL" elev))
              (vl-catch-all-apply 'vla-put-ScaleFactor (list tx 0.4))
              (vla-put-Rotation tx (- ang (* 0.5 pi)))
              (setq qs (1+ qs))))))))
  ;; bookkeeping and draw order : markings above the surface, below all lines
  (setq new (rp:since mark))
  (vlax-ldata-put obj "ROADPRO_MKMAN" (mapcar '(lambda (x) (cdr (assoc 5 (entget x)))) new))
  (vlax-ldata-put obj "ROADPRO_MKQTY" (list qe qc qs))
  (foreach x new
    (if (= (cdr (assoc 0 (entget x))) "HATCH") (setq sh (cons x sh)) (setq oth (cons x oth))))
  (if sh (rp:order-ss (reverse sh) "_B"))
  (if oth (rp:order-ss (reverse oth) "_B"))
  (setq sh (ssget "_X" '((0 . "HATCH") (8 . "ROAD-SURFACE,ROAD-SHOULDER"))))
  (if sh (command "_.DRAWORDER" sh "" "_B"))
  (setq *rp:mkcg* nil)
  (princ (strcat "\n  Road markings : yellow edge lines " (rtos (/ qe fac) 2 1) " m, white centre lines "
                 (rtos (/ qc fac) 2 1) " m, SLOW x " (itoa qs) "."))
  (princ))

;;============================================================================
;;  v3.4  CORRIDOR
;;  Lanes (by road width / manual / automatic), single or dual carriageway,
;;  median (flush painted or raised kerbed), sidewalks left / right, walkways,
;;  drainage provision, utility corridor provision, interlocking paver hatch.
;;  Everything is stored on the centre line and can be regenerated (RDU),
;;  edited (RDC) or rebuilt after a radius change (RDER / RDB).
;;  Drainage and utilities are GEOMETRIC PROVISIONS ONLY (no hydraulic or
;;  utility design).  Lane counts from the automatic mode are INDICATIVE.
;;============================================================================
(setq *rp:cdefaults*
  '(("ccarr" . "0")    ("clmode" . "0")   ("clanl" . "1")    ("clanr" . "1")
    ("clw" . "3.65")   ("cvol" . "0")     ("ccap" . "1800")
    ("cmed" . "0")     ("cmedw" . "3.00")
    ("cswl" . "0")     ("cswr" . "0")     ("cswlw" . "2.00") ("cswrw" . "2.00") ("cswo" . "0.00")
    ("cwkl" . "0")     ("cwkr" . "0")     ("cwkw" . "2.50")  ("cwko" . "1.00")
    ("cdrl" . "0")     ("cdrr" . "0")     ("cdrt" . "0")     ("cdrw" . "1.00")  ("cdrd" . "0.60") ("cdro" . "0.50")
    ("cutl" . "0")     ("cutr" . "0")     ("cutw" . "2.00")  ("cuto" . "0.50")
    ("cpav" . "1")     ("cpat" . "0")     ("cpatn" . "AR-B816") ("cpsc" . "1.0") ("cpang" . "0")))
(setq *rp:ckeys*    (mapcar 'car *rp:cdefaults*)
      *rp:defaults* (append *rp:defaults* *rp:cdefaults* '(("keep" . "1")))
      *rp:keys*     (append *rp:keys* '("keep")))

;; Interlocking paver (I-shape / dog-bone) 200 x 165 mm, defined in metres.
;; Lattice (0.20, 0) and (0.10, 0.1155); verified against the true tiling.
(setq *rp:paver-pat*
  '("*RP_PAVER, RoadPro interlocking paver (I-shape) 200 x 165 mm - 1 unit = 1 m"
    "0, -0.05, 0, 0.1, 0.1155, 0.1, -0.1"
    "0, 0.05, 0.0495, 0.1, 0.1155, 0.1, -0.1"
    "90, 0, 0, 0.1155, 0.1, 0.165, -0.066"
    "90, 0.05, 0, 0, 0.1, 0.0495, -0.066"))

;; ---- settings access : road snapshot (*rp:cset*) or overrides (*rp:cov*) first
(defun rp:cv (k / a)
  (cond ((and *rp:cov* (setq a (assoc k *rp:cov*))) (cdr a))
        ((and *rp:cset* (setq a (assoc k *rp:cset*))) (cdr a))
        (T (rp:val k))))
(defun rp:cn (k / v) (if (setq v (rp:dist (rp:cv k))) v (rp:dist (cdr (assoc k *rp:defaults*)))))
(defun rp:con (k) (= (rp:cv k) "1"))
(defun rp:int-p (v) (and v (< (abs (- v (fix (+ v (if (< v 0) -0.5 0.5))))) 1e-9)))

;; Settings snapshot of every RoadPro key (stored on the road)
(defun rp:snapshot () (mapcar '(lambda (k) (cons k (rp:val k))) (mapcar 'car *rp:defaults*)))

;; Run function fn (no arguments) with the settings of alist s, restore afterwards
(defun rp:with-settings (s fn / old r)
  (setq old (mapcar '(lambda (p) (cons (car p) (getenv (strcat "RoadPro_" (car p))))) s))
  (foreach p s (rp:set (car p) (cdr p)))
  (setq r (vl-catch-all-apply fn nil))
  (foreach p old (setenv (strcat "RoadPro_" (car p)) (if (cdr p) (cdr p) "")))
  r)

;;----------------------------------------------------------------------------
;;  Lane plan.  width = RDP road width (m).  Returns
;;   (W nl nr lw mw mo msgs)  W edge-to-edge width, nl / nr lanes left / right
;;   (0 = lane lines not drawn), lw lane width, mw median / separator width,
;;   mo offset of the median or direction line from the CL (+ = left), all m.
;;  Traffic keeps right : the RIGHT side carries traffic towards increasing
;;  chainage, the LEFT side the opposite direction.
;;----------------------------------------------------------------------------
(defun rp:lane-plan (width / carr lm med lw vol cap ct mw nmin n per nl nr ww mo msgs)
  (setq carr (rp:cv "ccarr") lm (rp:cv "clmode") med (rp:cv "cmed") ct (rp:cv "ctype")
        lw   (rp:cn "clw")   vol (rp:cn "cvol")  cap (rp:cn "ccap")
        mw   (cond ((/= med "0") (rp:cn "cmedw"))
                   ((and (= carr "1") (member ct '("1" "2"))) (rp:cn "bwid"))
                   (T 0.0))
        nmin (if (= carr "1") 2 1))
  (cond
    ((= lm "1")
     (setq nl (fix (+ 0.5 (rp:cn "clanl"))) nr (fix (+ 0.5 (rp:cn "clanr")))
           ww (+ (* (+ nl nr) lw) mw)
           msgs (list (strcat "Manual lanes: " (itoa nl) " left + " (itoa nr) " right x "
                              (rtos lw 2 2) " m" (if (> mw 0.0) (strcat " + median " (rtos mw 2 2) " m") "")
                              " = road width " (rtos ww 2 2) " m"))))
    ((= lm "2")
     (if (and vol (> vol 0.0) cap (> cap 0.0))
       (setq n    (max nmin (fix (+ 0.999999 (/ vol cap))))
             msgs (list (strcat "Automatic lanes: design volume " (rtos vol 2 0) " veh/h per direction / capacity "
                                (rtos cap 2 0) " veh/h/lane = " (itoa n) " lane(s) per direction (minimum "
                                (itoa nmin) " for a " (if (= carr "1") "dual" "single") " carriageway)")))
       (setq per  (* 0.5 (- width mw))
             n    (max nmin (fix (+ 1e-6 (/ per lw))))
             msgs (list (strcat "Automatic lanes: no traffic volume given - from the road width " (rtos width 2 2)
                                " m: " (itoa n) " lane(s) of " (rtos lw 2 2) " m per direction (minimum " (itoa nmin) ")"))))
     (setq nl n nr n ww (+ (* 2 n lw) mw))
     (setq msgs (append msgs
                        (list (strcat "Road width becomes " (rtos ww 2 2) " m.")
                              "Indicative only - NOT an engineering approval. Confirm with a traffic study and the project design standard."))))
    (T (setq nl 0 nr 0 ww width)))
  (setq mo (if (and (> nl 0) (> nr 0)) (* 0.5 (- nr nl) lw) 0.0))
  (list ww nl nr lw mw mo msgs))

;;----------------------------------------------------------------------------
;;  Validation of the corridor settings.  Returns (errors warnings)
;;----------------------------------------------------------------------------
(defun rp:corr-check (width / er wa v k pl lw nl nr mw carr med lm per chk)
  (setq carr (rp:cv "ccarr") med (rp:cv "cmed") lm (rp:cv "clmode"))
  ;; numbers that must be valid (key name may-be-zero relevant)
  (setq chk (list (list "clw"   "Lane width"                    nil (/= lm "0"))
                  (list "clanl" "Lanes left"                    nil (= lm "1"))
                  (list "clanr" "Lanes right"                   nil (= lm "1"))
                  (list "cvol"  "Design volume"                 T   (= lm "2"))
                  (list "ccap"  "Lane capacity"                 nil (= lm "2"))
                  (list "cmedw" "Median width"                  nil (/= med "0"))
                  (list "cswlw" "Left sidewalk width"           nil (rp:con "cswl"))
                  (list "cswrw" "Right sidewalk width"          nil (rp:con "cswr"))
                  (list "cswo"  "Sidewalk gap"                  T   (or (rp:con "cswl") (rp:con "cswr")))
                  (list "cwkw"  "Walkway width"                 nil (or (rp:con "cwkl") (rp:con "cwkr")))
                  (list "cwko"  "Walkway verge"                 T   (or (rp:con "cwkl") (rp:con "cwkr")))
                  (list "cdrw"  "Drain width / pipe diameter"   nil (or (rp:con "cdrl") (rp:con "cdrr")))
                  (list "cdrd"  "Drain depth"                   nil (or (rp:con "cdrl") (rp:con "cdrr")))
                  (list "cdro"  "Drain gap"                     T   (or (rp:con "cdrl") (rp:con "cdrr")))
                  (list "cutw"  "Utility corridor width"        nil (or (rp:con "cutl") (rp:con "cutr")))
                  (list "cuto"  "Utility corridor gap"          T   (or (rp:con "cutl") (rp:con "cutr")))
                  (list "cpsc"  "Hatch scale"                   nil (rp:con "cpav"))))
  (foreach c chk
    (if (cadddr c)
      (progn
        (setq v (rp:dist (rp:cv (car c))))
        (cond ((null v) (setq er (cons (strcat (cadr c) " is not a number.") er)))
              ((and (caddr c) (< v 0.0)) (setq er (cons (strcat (cadr c) " must be zero or more.") er)))
              ((and (not (caddr c)) (<= v 0.0)) (setq er (cons (strcat (cadr c) " must be greater than zero.") er)))))))
  (if (and (rp:con "cpav") (= (rp:cv "cpat") "2") (= (vl-string-trim " " (rp:cv "cpatn")) ""))
    (setq er (cons "Enter the hatch pattern name for walkways." er)))
  (if (null (rp:dist (rp:cv "cpang"))) (setq er (cons "Hatch angle is not a number." er)))
  (if (not er)
    (progn
      (setq lw (rp:cn "clw"))
      (if (/= lm "0")
        (cond ((or (< lw 2.5) (> lw 5.0)) (setq er (cons "Lane width must be between 2.50 and 5.00 m." er)))
              ((or (< lw 3.0) (> lw 3.75)) (setq wa (cons (strcat "Lane width " (rtos lw 2 2) " m is outside the usual 3.00 - 3.75 m.") wa)))))
      (if (= lm "1")
        (foreach k '(("clanl" "left") ("clanr" "right"))
          (setq v (rp:cn (car k)))
          (cond ((or (not (rp:int-p v)) (< v 1) (> v 8))
                 (setq er (cons (strcat "Lanes on the " (cadr k) " side must be a whole number from 1 to 8.") er)))
                ((> v 4) (setq wa (cons (strcat (rtos v 2 0) " lanes on the " (cadr k) " side - check the design.") wa))))))
      (if (and (= lm "2") (> (rp:cn "cvol") 0.0) (> (/ (rp:cn "cvol") (rp:cn "ccap")) 6.0))
        (setq wa (cons "Automatic: more than 6 lanes per direction - check volume and capacity." wa)))
      (if (and (= lm "1") (= carr "1")
               (or (< (rp:cn "clanl") 2) (< (rp:cn "clanr") 2)))
        (setq wa (cons "Dual carriageway with a single lane in one direction - check the design." wa)))
      (if (/= med "0")
        (progn
          (setq mw (rp:cn "cmedw"))
          (cond ((< mw 0.3) (setq er (cons "Median width must be at least 0.30 m." er)))
                ((and (= med "2") (< mw 1.2)) (setq wa (cons "Raised median narrower than 1.20 m." wa))))))
      (if (and (= carr "1") (= med "0") (not (member (rp:cv "ctype") '("1" "2"))))
        (setq er (cons "Dual carriageway needs a separation: choose a median, or Centre = barricades / cones (RDP)." er)))
      (setq pl (rp:lane-plan width) mw (nth 4 pl))
      (if (= lm "0")
        (progn
          (setq per (if (= carr "1") (* 0.5 (- width mw)) (if (> mw 0.0) (* 0.5 (- width mw)) (* 0.5 width))))
          (cond ((< per 2.5) (setq er (cons (strcat "Each carriageway would be only " (rtos per 2 2) " m wide - increase the road width or reduce the median.") er)))
                ((< per 3.0) (setq wa (cons (strcat "Each carriageway is only " (rtos per 2 2) " m wide.") wa))))))
      (foreach k '(("cswl" "cswlw" "Left sidewalk") ("cswr" "cswrw" "Right sidewalk"))
        (if (and (rp:con (car k)) (< (rp:cn (cadr k)) 1.5))
          (setq wa (cons (strcat (caddr k) " narrower than 1.50 m.") wa))))
      (if (and (or (rp:con "cwkl") (rp:con "cwkr")) (< (rp:cn "cwkw") 1.5))
        (setq wa (cons "Walkway narrower than 1.50 m." wa)))))
  (list (reverse er) (reverse wa)))

;;----------------------------------------------------------------------------
;;  Components beyond the road edges (all in drawing units).
;;  Returns list of (code sg o1 o2 width) : o1 / o2 = inner / outer distance
;;  beyond the carriageway edge line.  Order outwards : shoulder, edge
;;  treatment, sidewalk, walkway, drain, utility corridor.
;;----------------------------------------------------------------------------
(defun rp:corr-layout (bgap bwid el er fac / out sg base w g)
  (foreach sg '(1.0 -1.0)
    (setq base (+ bgap (if (if (> sg 0) el er) bwid 0.0)))
    (foreach c (list (list "SW" (if (> sg 0) "cswl" "cswr") (if (> sg 0) "cswlw" "cswrw") "cswo")
                     (list "WK" (if (> sg 0) "cwkl" "cwkr") "cwkw" "cwko")
                     (list "DR" (if (> sg 0) "cdrl" "cdrr") "cdrw" "cdro")
                     (list "UT" (if (> sg 0) "cutl" "cutr") "cutw" "cuto"))
      (if (rp:con (cadr c))
        (setq g    (* fac (rp:cn (cadddr c)))
              w    (* fac (rp:cn (caddr c)))
              out  (cons (list (car c) sg (+ base g) (+ base g w) w) out)
              base (+ base g w)))))
  (reverse out))

(defun rp:corr-any ()
  (or (/= (rp:cv "cmed") "0")
      (vl-some 'rp:con '("cswl" "cswr" "cwkl" "cwkr" "cdrl" "cdrr" "cutl" "cutr"))))

(defun rp:corr-summary (/ s)
  (setq s (strcat (if (= (rp:cv "ccarr") "1") "Dual" "Single") " carriageway, "
                  (cond ((= (rp:cv "clmode") "1") (strcat (rp:cv "clanl") "+" (rp:cv "clanr") " lanes"))
                        ((= (rp:cv "clmode") "2") "automatic lanes")
                        (T "lanes from road width"))
                  (cond ((= (rp:cv "cmed") "1") ", flush median") ((= (rp:cv "cmed") "2") ", raised median") (T ""))
                  (if (or (rp:con "cswl") (rp:con "cswr"))
                    (strcat ", sidewalk " (cond ((and (rp:con "cswl") (rp:con "cswr")) "both sides") ((rp:con "cswl") "left") (T "right"))) "")
                  (if (or (rp:con "cwkl") (rp:con "cwkr")) ", walkway" "")
                  (if (or (rp:con "cdrl") (rp:con "cdrr")) ", drain" "")
                  (if (or (rp:con "cutl") (rp:con "cutr")) ", utilities" "")))
  s)

;;----------------------------------------------------------------------------
;;  Hatches
;;----------------------------------------------------------------------------
;; Make sure RP_PAVER.pat can be found (written once to the roaming Support folder)
(defun rp:paver-file (/ fn f)
  (cond
    ((findfile "RP_PAVER.pat"))
    (T
     (setq fn (strcat (getvar "ROAMABLEROOTPREFIX") "Support\\RP_PAVER.pat"))
     (if (setq f (open fn "w"))
       (progn (foreach l *rp:paver-pat* (write-line l f)) (close f)))
     (findfile "RP_PAVER.pat"))))

;; New hatch for a corridor surface. kind : "PAV" walkway / sidewalk surface,
;; "MEDF" flush median, "SOLID", or a pattern name. ang = road direction.
(defun rp:chatch (kind elev fac ang / h nm typ sc iso)
  (setq iso (= (getvar "MEASUREMENT") 1)
        typ acHatchPatternTypePreDefined
        sc  1.0)
  (cond
    ((= kind "PAV")
     (cond ((not (rp:con "cpav")) (setq nm "SOLID"))
           ((and (= (rp:cv "cpat") "0") (rp:paver-file))
            (setq nm "RP_PAVER" typ acHatchPatternTypeCustomDefined sc fac))
           ((member (rp:cv "cpat") '("0" "1"))
            (setq nm "AR-HBONE" sc (* fac (if iso 0.001 0.0254))))
           (T (setq nm (strcase (vl-string-trim " " (rp:cv "cpatn"))) sc fac)))
     (setq sc  (* sc (rp:cn "cpsc"))
           ang (+ ang (* pi (/ (rp:cn "cpang") 180.0)))))
    ((= kind "MEDF") (setq nm "ANSI31" sc (* fac (if iso 0.315 8.0)) ang (+ ang (* 0.25 pi))))
    (T (setq nm kind)))
  (setq h (vl-catch-all-apply 'vla-AddHatch (list *rp:spc* typ nm :vlax-false)))
  (if (and (vl-catch-all-error-p h) (= kind "PAV"))
    (progn
      (princ (strcat "\n  Hatch pattern " nm " not available - using AR-HBONE herringbone."))
      (setq nm "AR-HBONE" sc (* fac (if iso 0.001 0.0254) (rp:cn "cpsc"))
            h  (vl-catch-all-apply 'vla-AddHatch (list *rp:spc* acHatchPatternTypePreDefined nm :vlax-false)))))
  (if (vl-catch-all-error-p h)
    (setq nm "SOLID" h (vla-AddHatch *rp:spc* acHatchPatternTypePreDefined "SOLID" :vlax-false)))
  (vla-put-Elevation h elev)
  (if (/= nm "SOLID")
    (progn
      (vl-catch-all-apply 'vla-put-PatternAngle (list h ang))
      (vl-catch-all-apply 'vla-put-PatternScale (list h sc))))
  h)

;;----------------------------------------------------------------------------
;;  Plan drawing helpers
;;----------------------------------------------------------------------------
;; Edge distance from the CL on one side at station d : tapers tp + widenings wp
(defun rp:edge-at (tp wp hw d / o)
  (setq o (rp:soff tp hw d))
  (foreach w wp (setq o (+ o (rp:prof-o w d))))
  o)

;; Strip on side sg between stations a and b, from r1 to r2 beyond the edge
;; (tapers tp / widenings wp; hw = 0 and sg = 1 gives plain CL offsets).
;; kind = hatch kind or nil. lines = T draws both boundary lines on lay.
;; Returns (length area)
(defun rp:cband (cl a b sg r1 r2 tp wp hw lay kind elev fac lines / s0 s1 n i d ed pa pb bnd h ar ang)
  (setq s0 a ar 0.0)
  (while (< s0 (- b 1e-6))
    (setq s1 (min b (+ s0 (* 25.0 fac)))
          n  (max 1 (fix (+ 0.999999 (/ (- s1 s0) fac))))
          i  0 pa nil pb nil)
    (repeat (1+ n)
      (setq d  (+ s0 (* (- s1 s0) (/ (float i) n)))
            ed (rp:edge-at tp wp hw d)
            pa (cons (rp:offpt cl d (* sg (+ ed r1))) pa)
            pb (cons (rp:offpt cl d (* sg (+ ed r2))) pb)
            i  (1+ i)))
    (setq bnd (rp:poly (append (reverse pa) pb) lay elev)
          ar  (+ ar (vla-get-Area bnd)))
    (if kind
      (progn
        (setq ang (angle '(0.0 0.0) (caddr (rp:frame cl (* 0.5 (+ s0 s1)))))
              h   (rp:chatch kind elev fac ang))
        (vla-put-Layer h lay)
        (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-AppendOuterLoop (list h (rp:objarr (list bnd)))))
          (vla-Delete h)
          (progn (vl-catch-all-apply 'vla-Evaluate (list h)) (setq *rp:hatches* (cons h *rp:hatches*))))))
    (vla-Delete bnd)
    (setq s0 s1))
  (if lines
    (foreach r (list r1 r2)
      (setq i 0 pa nil n (max 1 (fix (+ 0.999999 (/ (- b a) fac)))))
      (repeat (1+ n)
        (setq d  (+ a (* (- b a) (/ (float i) n)))
              pa (cons (list (rp:offpt cl d (* sg (+ (rp:edge-at tp wp hw d) r))) 0.0) pa)
              i  (1+ i)))
      (rp:mkpl (reverse pa) lay elev nil)))
  (list (- b a) ar))

;; Line along the road at distance r beyond the edge (one polyline)
(defun rp:cline (cl a b sg r tp wp hw lay elev fac / i n d pa)
  (setq i 0 n (max 1 (fix (+ 0.999999 (/ (- b a) fac)))))
  (repeat (1+ n)
    (setq d  (+ a (* (- b a) (/ (float i) n)))
          pa (cons (list (rp:offpt cl d (* sg (+ (rp:edge-at tp wp hw d) r))) 0.0) pa)
          i  (1+ i)))
  (rp:mkpl (reverse pa) lay elev nil))

;; Label along the road every 100 m (at least once) at side offset off
(defun rp:clabels (cl a b sg r tp wp hw txt th elev fac lay / d f ang tx s step)
  (setq step (* 100.0 fac)
        d    (+ a (min (* 0.5 (- b a)) (* 15.0 fac))))
  (while (< d b)
    (setq f   (rp:frame cl d)
          ang (angle '(0.0 0.0) (caddr f))
          tx  (rp:text txt (rp:offpt cl d (* sg (+ (rp:edge-at tp wp hw d) r))) th lay elev))
    (if (and (> ang (* 0.5 pi)) (<= ang (* 1.5 pi))) (setq ang (+ ang pi)))
    (vla-put-Rotation tx ang)
    (setq d (+ d step)))
  (princ))

;; Ticks across a strip every sp (covered drains : grating marks)
(defun rp:cticks (cl a b sg r1 r2 tp wp hw sp lay elev / d ed)
  (setq d (+ a (* 0.5 sp)))
  (while (< d b)
    (setq ed (rp:edge-at tp wp hw d))
    (rp:line (rp:offpt cl d (* sg (+ ed r1))) (rp:offpt cl d (* sg (+ ed r2))) lay elev)
    (setq d (+ d sp)))
  (princ))

;;----------------------------------------------------------------------------
;;  Draw (or redraw) the corridor of a road : median + components.
;;  Uses the road's own stored settings. Removes the previous corridor.
;;----------------------------------------------------------------------------
(defun rp:corr-run (e / data fac obj len hw elev bgap bwid el er mw mo med gaps recs th q warn
                        mark new hd en lo hi kw r c sg tp wp kg mg gg cg jg jd jcs pcs code o1 o2 w ln ar
                        curves lay kind dt hsh oth rg rec wrap kk cut pa mlen x)
  (setq data (rp:xget e)
        fac  (atof (rp:xv "FAC" data)))
  (if (<= fac 0.0) (setq fac 1.0))
  (setq obj   (vlax-ename->vla-object e)
        *rp:cset* (vlax-ldata-get obj "ROADPRO_SET")
        len   (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
        *rp:len* len
        hw    (* 0.5 fac (atof (rp:xv "W" data)))
        elev  (vla-get-Elevation obj)
        bgap  (* fac (atof (rp:xv "BGAP" data)))
        bwid  (* fac (atof (rp:xv "BWID" data)))
        el    (rp:edge-on data 1.0)
        er    (rp:edge-on data -1.0)
        mw    (* fac (atof (rp:xv "MW" data)))
        mo    (* fac (atof (rp:xv "MO" data)))
        med   (rp:xv "MED" data)
        gaps  (vlax-ldata-get obj "ROADPRO_MKGAP")
        recs  (vlax-ldata-get obj "ROADPRO_TAPERS")
        jcs   (vlax-ldata-get obj "ROADPRO_JCORN")
        cg    (mapcar '(lambda (g) (list (nth 2 g) (nth 3 g))) (vl-remove-if-not '(lambda (g) (= (car g) "C")) gaps))
        curves (rp:curves obj)
        th    (* 0.6 fac (rp:cn "txth"))
        dt    (rp:cv "cdrt")
        *rp:hatches* nil
        q nil warn nil)
  ;; remove the previous corridor of this road
  (foreach hd (vlax-ldata-get obj "ROADPRO_CORR")
    (if (and (setq en (handent hd)) (entget en)) (entdel en)))
  (setq mark (entlast))
  ;; ---- median (stops at roundabouts : "C" gaps) ----
  (if (and (member med '("1" "2")) (> mw 0.0))
    (progn
      (setq lo (- mo (* 0.5 mw)) hi (+ mo (* 0.5 mw)) kw (min (* 0.15 fac) (* 0.25 mw)) mlen 0.0)
      (foreach rg (rp:mk-ranges 0.0 len cg)
        (setq *rp:len* len
              mlen (+ mlen (- (cadr rg) (car rg))))
        (if (= med "2")
          (progn
            (rp:cband obj (car rg) (cadr rg) 1.0 lo (+ lo kw) nil nil 0.0 "ROAD-MEDIAN-KERB" "SOLID" elev fac T)
            (rp:cband obj (car rg) (cadr rg) 1.0 (- hi kw) hi nil nil 0.0 "ROAD-MEDIAN-KERB" "SOLID" elev fac T)
            (rp:cband obj (car rg) (cadr rg) 1.0 (+ lo kw) (- hi kw) nil nil 0.0 "ROAD-MEDIAN" "SOLID" elev fac nil))
          (rp:cband obj (car rg) (cadr rg) 1.0 lo hi nil nil 0.0 "ROAD-MEDIAN" "MEDF" elev fac T))
        (rp:clabels obj (car rg) (cadr rg) 1.0 mo nil nil 0.0
                    (strcat (if (= med "2") "RAISED MEDIAN " "FLUSH MEDIAN ") (rtos (/ mw fac) 2 2) " m")
                    th elev fac "ROAD-MEDIAN"))
      (setq q (cons (list "MED" 0.0 (if (= med "2") "Median - raised (kerbed)" "Median - flush (painted)")
                          (/ mw fac) (/ mlen fac) (/ (* mw mlen) fac fac))
                    q))))
  ;; ---- sidewalks, walkways, drains, utility corridor ----
  (foreach c (rp:corr-layout bgap bwid el er fac)
    (setq code (car c) sg (cadr c) o1 (caddr c) o2 (cadddr c) w (nth 4 c)
          *rp:len* len
          tp   (rp:taper-profs recs sg fac)
          wp   (mapcar 'caddr (vl-remove-if-not '(lambda (g) (and (= (car g) "W") (= (cadr g) sg))) gaps))
          kg   (mapcar '(lambda (g) (list (nth 2 g) (nth 3 g)))
                       (vl-remove-if-not '(lambda (g) (and (= (car g) "K") (= (cadr g) sg))) gaps))
          mg   (mapcar '(lambda (g) (list (nth 2 g) (nth 3 g)))
                       (vl-remove-if-not '(lambda (g) (and (= (car g) "M") (= (cadr g) sg))) gaps))
          gg   (mapcar '(lambda (g) (list (nth 2 g) (nth 3 g)))
                       (vl-remove-if-not '(lambda (g) (and (= (car g) "G") (= (cadr g) sg))) gaps))
          lay  (cdr (assoc code '(("SW" . "ROAD-SIDEWALK") ("WK" . "ROAD-WALKWAY") ("DR" . "ROAD-DRAIN") ("UT" . "ROAD-UTILITY"))))
          jg   nil jd nil ln 0.0 ar 0.0)
    ;; v3.5 : junction / roundabout corners - the strip wraps round the kerb line
    (foreach rec jcs
      (if (= (nth 1 rec) sg)
        (progn
          (setq wrap (or (= (nth 7 rec) "ALL") (member code '("SW" "WK")) (and (= code "DR") (/= dt "2"))))
          (cond
            (wrap
             (setq kk (list (rp:k-off (nth 4 rec) o1 (nth 5 rec) elev) (rp:k-off (nth 4 rec) o2 (nth 5 rec) elev)))
             (if (and (car kk) (cadr kk))
               (progn
                 (setq cut (rp:jc-cutsta obj kk T (nth 2 rec) (nth 3 rec))
                       jg  (cons (list (min cut (nth 2 rec)) (max cut (nth 2 rec))) jg))
                 (if (= (nth 6 rec) 1) (setq jd (cons (list rec kk cut) jd))))))
            ((= (nth 8 rec) "B")
             (if (setq cut (rp:jc-tjoin rec o1 o2 obj elev))
               (setq jg (cons (list (min cut (nth 2 rec)) (max cut (nth 2 rec))) jg))))))))
    (setq pcs (rp:mk-ranges 0.0 len
                (append kg gg jg (if (or (member code '("SW" "WK")) (and (= code "DR") (/= dt "2"))) mg))))
    ;; inside of tight bends
    (foreach cv curves
      (if (and (= (nth 4 cv) (fix sg)) (>= (+ hw o2) (nth 2 cv)))
        (setq warn (cons (strcat (rp:cname code sg) " is wider than the radius on the inside of the bend at CH "
                                 (rp:chfmt (+ (atof (rp:xv "CHST" data)) (/ (car cv) fac)))
                                 " (R " (rtos (/ (nth 2 cv) fac) 2 2) " m) - it will overlap itself.")
                         warn))))
    (foreach rg pcs
      (setq *rp:len* len)
      (cond
        ((member code '("SW" "WK"))
         (setq r (rp:cband obj (car rg) (cadr rg) sg o1 o2 tp wp hw lay "PAV" elev fac T)))
        ((= code "DR")
         (cond
           ((= dt "2")      ; stormwater pipe : centre line + pipe walls
            (rp:cline obj (car rg) (cadr rg) sg (* 0.5 (+ o1 o2)) tp wp hw lay elev fac)
            (setq r (rp:cband obj (car rg) (cadr rg) sg o1 o2 tp wp hw lay nil elev fac T)))
           ((= dt "1")      ; covered U-channel : walls + grating ticks
            (setq r (rp:cband obj (car rg) (cadr rg) sg o1 o2 tp wp hw lay nil elev fac T))
            (rp:cticks obj (car rg) (cadr rg) sg o1 o2 tp wp hw (* 2.0 fac) lay elev))
           (T               ; open channel : top of banks + invert line, light fill
            (setq r (rp:cband obj (car rg) (cadr rg) sg o1 o2 tp wp hw lay "ANSI37" elev fac T))
            (rp:cline obj (car rg) (cadr rg) sg (* 0.5 (+ o1 o2)) tp wp hw lay elev fac))))
        ((= code "UT")
         (setq r (rp:cband obj (car rg) (cadr rg) sg o1 o2 tp wp hw lay nil elev fac T))))
      (setq ln (+ ln (car r)) ar (+ ar (cadr r)))
      (rp:clabels obj (car rg) (cadr rg) sg (* 0.5 (+ o1 o2)) tp wp hw (rp:clabel-txt code w fac) th elev fac lay))
    ;; v3.5 : the corner pieces (hatched like the strip)
    (foreach x jd
      (setq pa (rp:jc-draw (car x) (cadr x) (caddr x) obj lay
                           (cond ((member code '("SW" "WK")) "PAV") ((and (= code "DR") (= dt "0")) "ANSI37") (T nil))
                           T elev fac)
            ar (+ ar pa)
            ln (+ ln (if (> w 0.0) (/ pa w) 0.0))))
    (setq q (cons (list code sg (rp:cname code sg) (/ w fac) (/ ln fac) (/ ar fac fac)) q)))
  ;; ---- bookkeeping, draw order : surfaces under everything, road surface lowest ----
  (setq new (rp:since mark))
  (vlax-ldata-put obj "ROADPRO_CORR" (mapcar '(lambda (x) (cdr (assoc 5 (entget x)))) new))
  (vlax-ldata-put obj "ROADPRO_CQTY" (reverse q))
  (foreach x new (if (= (cdr (assoc 0 (entget x))) "HATCH") (setq hsh (cons x hsh)) (setq oth (cons x oth))))
  (if hsh (rp:order-ss (reverse hsh) "_B"))
  (setq hsh (ssget "_X" '((0 . "HATCH") (8 . "ROAD-SURFACE,ROAD-SHOULDER"))))
  (if hsh (command "_.DRAWORDER" hsh "" "_B"))
  (rp:track e mark)
  (foreach x (reverse warn) (princ (strcat "\n  Warning: " x)))
  (setq *rp:cset* nil)
  (length q))

(defun rp:cname (code sg)
  (strcat (cdr (assoc code '(("SW" . "Sidewalk") ("WK" . "Walkway") ("DR" . "Drain") ("UT" . "Utility corridor") ("MED" . "Median"))))
          (cond ((= sg 1.0) " - left") ((= sg -1.0) " - right") (T ""))))

(defun rp:clabel-txt (code w fac / dt)
  (setq dt (rp:cv "cdrt"))
  (cond ((= code "SW") (strcat "SIDEWALK " (rtos (/ w fac) 2 2) " m"))
        ((= code "WK") (strcat "WALKWAY " (rtos (/ w fac) 2 2) " m"))
        ((= code "DR")
         (cond ((= dt "2") (strcat "SW PIPE DN" (rtos (* 1000.0 (/ w fac)) 2 0) " (PROVISION)"))
               ((= dt "1") (strcat "COVERED U-CHANNEL " (rtos (/ w fac) 2 2) " x " (rtos (rp:cn "cdrd") 2 2) " m (PROVISION)"))
               (T (strcat "OPEN DRAIN " (rtos (/ w fac) 2 2) " x " (rtos (rp:cn "cdrd") 2 2) " m (PROVISION)"))))
        (T (strcat "UTILITY CORRIDOR " (rtos (/ w fac) 2 2) " m (PROVISION)"))))

;; Report rows for the corridor of a road
(defun rp:corr-rows (obj data / q rows sn lm nl nr lw)
  (setq sn  (vlax-ldata-get obj "ROADPRO_SET")
        q   (vlax-ldata-get obj "ROADPRO_CQTY")
        lm  (rp:xv "LMODE" data)
        nl  (rp:xv "NL" data) nr (rp:xv "NR" data))
  (if (or q (member lm '("1" "2")) (= (rp:xv "CARR" data) "1"))
    (progn
      (setq *rp:cset* sn)
      (setq rows
        (append
          (list '("#" "CROSS SECTION / CORRIDOR")
                (list "Carriageway" (if (= (rp:xv "CARR" data) "1") "Dual (two carriageways)" "Single"))
                (list "Lanes"
                      (if (and (/= nl "") (> (atoi nl) 0))
                        (strcat nl " left + " nr " right  x  " (rp:xv "LW" data) " m")
                        "From road width (no lane lines)"))
                (list "Lane selection"
                      (cond ((= lm "1") "Manual")
                            ((= lm "2") (strcat "Automatic - indicative only, not engineering approved"
                                                (if (> (rp:cn "cvol") 0.0)
                                                  (strcat " (V " (rp:cv "cvol") " veh/h/dir, C " (rp:cv "ccap") " veh/h/lane)")
                                                  " (from road width)")))
                            (T "By road width"))))
          (mapcar '(lambda (x)
                     (list (nth 2 x)
                           (strcat (rtos (nth 3 x) 2 2) " m wide,  length " (rtos (nth 4 x) 2 1) " m,  area "
                                   (rtos (nth 5 x) 2 2) " m2"
                                   (if (member (car x) '("SW" "WK"))
                                     (if (rp:con "cpav")
                                       (cond ((= (rp:cv "cpat") "0") "  (interlocking paver)")
                                             ((= (rp:cv "cpat") "1") "  (herringbone paver)")
                                             (T (strcat "  (" (rp:cv "cpatn") ")")))
                                       "")
                                     ""))))
                  q)
          (if (vl-some '(lambda (x) (member (car x) '("DR" "UT"))) q)
            (list (list "Drainage / utilities" "Geometric provision only - no hydraulic or utility design")))))))
  (setq *rp:cset* nil)
  rows)

;; Track every object created since mark as part of road e (for rebuilds)
(defun rp:track (e mark / obj)
  (setq obj (vlax-ename->vla-object e))
  (vlax-ldata-put obj "ROADPRO_ALL"
                  (append (vlax-ldata-get obj "ROADPRO_ALL")
                          (mapcar '(lambda (x) (cdr (assoc 5 (entget x)))) (rp:since mark))))
  (princ))

;;----------------------------------------------------------------------------
;;  v3.4 helpers : lane lines, label offsets, cross-section corridor
;;----------------------------------------------------------------------------
;; Broken white lane line (L1 by speed) at side offset o along the whole road.
;; Returns the painted length.
(defun rp:mk-broken (obj len o spdm fac elev / d de pt q)
  (setq d 0.0 q 0.0 pt (rp:l1 spdm))
  (while (< d len)
    (setq de (min len (+ d (* fac (car pt)))))
    (if (and (> (- de d) (* 0.5 fac)) (not (rp:mk-inside (* 0.5 (+ d de)) *rp:mkcg*)))
      (progn
        (rp:mk-strip obj d de 1.0 nil 0.0 fac elev nil "ROAD-MARKING-FILL" (- o (* 0.05 fac)) (+ o (* 0.05 fac)))
        (setq q (+ q (- de d)))))
    (setq d (+ d (* fac (+ (car pt) (cadr pt))))))
  q)

;; Extra room taken by corridor items on side sg beyond the edge treatment
;; (current settings), drawing units
(defun rp:corr-extra (sg fac bgap bwid / m base)
  (setq base (+ bgap (if (rp:con (if (> sg 0) "bl" "br")) bwid 0.0)) m base)
  (foreach c (rp:corr-layout bgap bwid (rp:con "bl") (rp:con "br") fac)
    (if (= (cadr c) sg) (setq m (max m (cadddr c)))))
  (- m base))

;; ---- cross section ----
;; outer extent of corridor items on side sg (beyond the carriageway edge)
(defun rp:xc-ext2 (sg / m)
  (setq m 0.0)
  (if *rp:xc* (foreach c (nth 6 *rp:xc*) (if (= (cadr c) sg) (setq m (max m (cadddr c))))))
  m)

(defun rp:xc-ext () (max (rp:xc-ext2 1.0) (rp:xc-ext2 -1.0)))

;; add lane, median and corridor boundaries to the dimension chain xs
(defun rp:xc-dims (xs hw / mw mo nl nr lw k out prev)
  (if *rp:xc*
    (progn
      (setq mw (nth 0 *rp:xc*) mo (nth 1 *rp:xc*) nl (nth 3 *rp:xc*) nr (nth 4 *rp:xc*) lw (nth 5 *rp:xc*))
      (if (> mw 0.0) (setq xs (append xs (list (- mo (* 0.5 mw)) (+ mo (* 0.5 mw))))))
      (if (> nl 0)
        (progn
          (setq k 1)
          (repeat (1- nl) (setq xs (cons (- mo (* 0.5 mw) (* k lw)) xs) k (1+ k)))
          (setq k 1)
          (repeat (1- nr) (setq xs (cons (+ mo (* 0.5 mw) (* k lw)) xs) k (1+ k)))))
      (foreach c (nth 6 *rp:xc*)
        (setq xs (append xs (list (* (- (cadr c)) (+ hw (caddr c))) (* (- (cadr c)) (+ hw (cadddr c)))))))))
  (foreach x (vl-sort xs '<)
    (if (or (null prev) (> (- x prev) 1e-6)) (setq out (cons x out) prev x)))
  (reverse out))

;; rectangle (x1 x2 y1 y2) filled on layer lay
(defun rp:xrect (x1 x2 y1 y2 lay)
  (rp:solidfill (rp:xpl (list (list x1 y1) (list x2 y1) (list x2 y2) (list x1 y2)) "ROAD-XSEC" T) nil lay 0.0))

;; Median, sidewalks, walkways, drains and utility corridor in a section.
;; Section coordinates : the road's LEFT side is on the LEFT (negative x);
;; *rp:xc* holds the median offset already in section coordinates.
(defun rp:xcorr (hw yL yR fac th / mw mo med comps lo hi kw c sg x1 x2 ye w d top tx k ny dt cy)
  (setq mw (nth 0 *rp:xc*) mo (nth 1 *rp:xc*) med (nth 2 *rp:xc*) comps (nth 6 *rp:xc*)
        kw (* 0.15 fac) ny 0)
  ;; ---- median ----
  (if (and (member med '("1" "2")) (> mw 0.0))
    (progn
      (setq lo (- mo (* 0.5 mw)) hi (+ mo (* 0.5 mw)))
      (if (= med "2")
        (progn
          (rp:xrect lo (+ lo kw) 0.0 (* 0.15 fac) "ROAD-XSEC-CONC")
          (rp:xrect (- hi kw) hi 0.0 (* 0.15 fac) "ROAD-XSEC-CONC")
          (if (> (- hi lo) (* 2.0 kw)) (rp:xrect (+ lo kw) (- hi kw) 0.0 (* 0.12 fac) "ROAD-MEDIAN"))
          (rp:xmtext (strcat "RAISED MEDIAN " (rtos (/ mw fac) 2 2) " m\\PKERBS 150 mm UPSTAND") (list mo (+ (* 0.15 fac) (* 2.6 th))) th))
        (progn
          (rp:xrect lo hi 0.0 (* 0.02 fac) "ROAD-MARKING-YELLOW")
          (rp:xmtext (strcat "FLUSH MEDIAN " (rtos (/ mw fac) 2 2) " m (PAINTED, HATCHED)") (list mo (* 2.2 th)) th)))))
  ;; ---- items beyond the edges ----
  (foreach c comps
    (setq sg (cadr c) w (nth 4 c)
          x1 (* (- sg) (+ hw (caddr c))) x2 (* (- sg) (+ hw (cadddr c)))
          ye (if (> sg 0) yL yR))
    (if (< x2 x1) (setq k x1 x1 x2 x2 k))
    (setq tx (* 0.5 (+ x1 x2)))
    (cond
      ((member (car c) '("SW" "WK"))
       (setq top (+ ye (if (= (car c) "SW") (* 0.15 fac) (* 0.05 fac))))
       (rp:xrect x1 x2 (- top (* 0.08 fac)) top (if (= (car c) "SW") "ROAD-SIDEWALK" "ROAD-WALKWAY"))
       (rp:xrect x1 x2 (- top (* 0.11 fac)) (- top (* 0.08 fac)) "ROAD-XSEC-L3")
       (rp:xrect x1 x2 (- top (* 0.26 fac)) (- top (* 0.11 fac)) "ROAD-XSEC-L2")
       (if (= (car c) "SW")
         (rp:xrect (if (> sg 0) (- x2 (* 0.12 fac)) x1) (if (> sg 0) x2 (+ x1 (* 0.12 fac))) (- top (* 0.40 fac)) top "ROAD-XSEC-CONC"))  ; kerb on the road side
       (rp:xcnote (strcat (if (= (car c) "SW") "SIDEWALK " "WALKWAY ") (rtos (/ w fac) 2 2) " m"
                          "\\PINTERLOCKING PAVERS 80 mm\\PON 30 mm SAND + 150 mm BASE")
                  tx top ny th))
      ((= (car c) "DR")
       (setq d (* fac (rp:cn "cdrd")) dt (rp:cv "cdrt"))
       (cond
         ((= dt "2")
          (setq cy (- ye d (* -0.5 w)))
          (vla-put-Layer (vla-AddCircle *rp:spc* (rp:p3 (rp:xp tx cy) 0.0) (* 0.5 w)) "ROAD-DRAIN")
          (rp:xcnote (strcat "SW PIPE DN" (rtos (* 1000.0 (/ w fac)) 2 0) "\\PINVERT -" (rtos (/ d fac) 2 2) " m\\P(PROVISION)")
                     tx ye ny th))
         ((= dt "1")
          (rp:solidfill (rp:xpl (list (list x1 (+ ye 0.0)) (list x2 ye) (list x2 (- ye d (* 0.1 fac))) (list x1 (- ye d (* 0.1 fac)))) "ROAD-XSEC" T)
                        (rp:xpl (list (list (+ x1 (* 0.1 fac)) ye) (list (- x2 (* 0.1 fac)) ye) (list (- x2 (* 0.1 fac)) (- ye d)) (list (+ x1 (* 0.1 fac)) (- ye d))) "ROAD-DRAIN" T)
                        "ROAD-XSEC-CONC" 0.0)
          (rp:xline (list x1 (+ ye (* 0.02 fac))) (list x2 (+ ye (* 0.02 fac))) "ROAD-DRAIN")
          (rp:xcnote (strcat "COVERED U-CHANNEL " (rtos (/ w fac) 2 2) " x " (rtos (/ d fac) 2 2) " m\\P(PROVISION)")
                     tx ye ny th))
         (T
          (setq k (rp:xpl (list (list x1 ye) (list (+ x1 (/ w 3.0)) (- ye d)) (list (- x2 (/ w 3.0)) (- ye d)) (list x2 ye)) "ROAD-DRAIN" nil))
          (vla-put-ConstantWidth k (* 0.03 fac))
          (rp:xcnote (strcat "OPEN DRAIN " (rtos (/ w fac) 2 2) " x " (rtos (/ d fac) 2 2) " m\\P(PROVISION)")
                     tx ye ny th))))
      ((= (car c) "UT")
       (setq k (rp:xpl (list (list x1 (- ye (* 0.6 fac))) (list x2 (- ye (* 0.6 fac))) (list x2 (- ye (* 1.2 fac))) (list x1 (- ye (* 1.2 fac)))) "ROAD-UTILITY" T))
       (rp:xmtext (strcat "UTILITY CORRIDOR " (rtos (/ w fac) 2 2) " m\\P(PROVISION)") (list tx (- ye (* 0.9 fac))) (* 0.8 th))))
    (if (/= (car c) "UT") (setq ny (rem (1+ ny) 3))))
  (princ))

;; v3.6 corridor item note on staggered tiers above the section, with a leader
(defun rp:xcnote (str tx ty k th / yb)
  (if *rp:xtier*
    (progn
      (setq yb (+ *rp:xtier* (* k 4.2 th)))
      (rp:xline (list tx ty) (list tx (- yb (* 0.3 th))) "ROAD-XSEC-THIN")
      (rp:xmtext str (list tx (+ yb (* 1.7 th))) (* 0.85 th)))
    (rp:xmtext str (list tx (+ ty (* 2.6 th))) (* 0.9 th))))

;; extra room of corridor items on side dir (+1 left / -1 right) for labels
(defun rp:cin (dir) (if *rp:cinx* (if (> dir 0) (car *rp:cinx*) (cadr *rp:cinx*)) 0.0))

;;----------------------------------------------------------------------------
;;  Corridor dialog (used by RDP "Lanes, median ..." button and by RDC)
;;----------------------------------------------------------------------------
(setq *rp:cdcl*
 (list
  "roadcorr : dialog {"
  "  label = \"ROAD PRO  -  Lanes, Median, Sidewalks, Drains and Utilities\";"
  "  : text { key = \"info\"; width = 90; }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Carriageway and lanes\";"
  "      : popup_list { key = \"ccarr\";  label = \"Carriageway:\";     edit_width = 26; }"
  "      : popup_list { key = \"clmode\"; label = \"Number of lanes:\"; edit_width = 26; }"
  "      : edit_box { key = \"clanl\"; label = \"Lanes, left side (opposite direction):\";   edit_width = 5; }"
  "      : edit_box { key = \"clanr\"; label = \"Lanes, right side (chainage direction):\";  edit_width = 5; }"
  "      : edit_box { key = \"clw\";   label = \"Lane width (m):\";                           edit_width = 5; }"
  "      : edit_box { key = \"cvol\";  label = \"Design volume per direction (veh/h, 0 = unknown):\"; edit_width = 6; }"
  "      : edit_box { key = \"ccap\";  label = \"Lane capacity assumed (veh/h/lane):\";       edit_width = 6; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Median\";"
  "      : popup_list { key = \"cmed\";  label = \"Median:\";          edit_width = 24; }"
  "      : edit_box   { key = \"cmedw\"; label = \"Median width (m):\"; edit_width = 6; }"
  "      : text { label = \"A dual carriageway needs a median or a\"; }"
  "      : text { label = \"centre barrier (RDP dialog : Centre).\"; }"
  "    }"
  "  }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Sidewalks and walkways\";"
  "      : row { : toggle { key = \"cswl\"; label = \"Sidewalk left\"; }"
  "              : edit_box { key = \"cswlw\"; label = \"width (m):\"; edit_width = 5; } }"
  "      : row { : toggle { key = \"cswr\"; label = \"Sidewalk right\"; }"
  "              : edit_box { key = \"cswrw\"; label = \"width (m):\"; edit_width = 5; } }"
  "      : edit_box { key = \"cswo\"; label = \"Gap behind the edge treatment (m):\"; edit_width = 5; }"
  "      : row { : toggle { key = \"cwkl\"; label = \"Walkway left\"; }"
  "              : toggle { key = \"cwkr\"; label = \"Walkway right\"; } }"
  "      : edit_box { key = \"cwkw\"; label = \"Walkway width (m):\";             edit_width = 5; }"
  "      : edit_box { key = \"cwko\"; label = \"Verge before the walkway (m):\";  edit_width = 5; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Drainage and utilities (geometric provision only)\";"
  "      : row { : toggle { key = \"cdrl\"; label = \"Drain left\"; }"
  "              : toggle { key = \"cdrr\"; label = \"Drain right\"; } }"
  "      : popup_list { key = \"cdrt\"; label = \"Drain type:\"; edit_width = 24; }"
  "      : edit_box { key = \"cdrw\"; label = \"Width / pipe diameter (m):\";  edit_width = 5; }"
  "      : edit_box { key = \"cdrd\"; label = \"Depth (m):\";                  edit_width = 5; }"
  "      : edit_box { key = \"cdro\"; label = \"Gap before the drain (m):\";   edit_width = 5; }"
  "      : row { : toggle { key = \"cutl\"; label = \"Utility corridor left\"; }"
  "              : toggle { key = \"cutr\"; label = \"right\"; } }"
  "      : edit_box { key = \"cutw\"; label = \"Corridor width (m):\";         edit_width = 5; }"
  "      : edit_box { key = \"cuto\"; label = \"Gap before the corridor (m):\"; edit_width = 5; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Sidewalk / walkway surface\";"
  "      : toggle     { key = \"cpav\";  label = \"Paver hatch\"; }"
  "      : popup_list { key = \"cpat\";  label = \"Pattern:\"; edit_width = 26; }"
  "      : edit_box   { key = \"cpatn\"; label = \"Other pattern name:\";     edit_width = 10; }"
  "      : edit_box   { key = \"cpsc\";  label = \"Scale (1 = real size):\";  edit_width = 6; }"
  "      : edit_box   { key = \"cpang\"; label = \"Extra angle (deg):\";      edit_width = 6; }"
  "    }"
  "  }"
  "  : boxed_column {"
  "    label = \"Check\";"
  "    : text { key = \"m1\"; width = 110; }"
  "    : text { key = \"m2\"; width = 110; }"
  "    : text { key = \"m3\"; width = 110; }"
  "  }"
  "  : row { : button { key = \"check\"; label = \"Check layout\"; width = 16; fixed_width = true; }"
  "          : text { label = \"Lane counts are indicative, not an engineering approval.\"; } }"
  "  : text { label = \"Developed by https://www.exceltokml.com/\"; alignment = right; }"
  "  ok_cancel;"
  "  errtile;"
  "}"))

(defun rp:cdlg-modes (/ lm any)
  (setq lm (get_tile "clmode"))
  (foreach k '("clanl" "clanr") (mode_tile k (if (= lm "1") 0 1)))
  (foreach k '("cvol" "ccap") (mode_tile k (if (= lm "2") 0 1)))
  (mode_tile "clw" (if (= lm "0") 1 0))
  (mode_tile "cmedw" (if (= (get_tile "cmed") "0") 1 0))
  (mode_tile "cswlw" (if (= (get_tile "cswl") "1") 0 1))
  (mode_tile "cswrw" (if (= (get_tile "cswr") "1") 0 1))
  (mode_tile "cswo" (if (or (= (get_tile "cswl") "1") (= (get_tile "cswr") "1")) 0 1))
  (setq any (or (= (get_tile "cwkl") "1") (= (get_tile "cwkr") "1")))
  (foreach k '("cwkw" "cwko") (mode_tile k (if any 0 1)))
  (setq any (or (= (get_tile "cdrl") "1") (= (get_tile "cdrr") "1")))
  (foreach k '("cdrt" "cdrw" "cdrd" "cdro") (mode_tile k (if any 0 1)))
  (setq any (or (= (get_tile "cutl") "1") (= (get_tile "cutr") "1")))
  (foreach k '("cutw" "cuto") (mode_tile k (if any 0 1)))
  (setq any (= (get_tile "cpav") "1"))
  (foreach k '("cpat" "cpsc" "cpang") (mode_tile k (if any 0 1)))
  (mode_tile "cpatn" (if (and any (= (get_tile "cpat") "2")) 0 1))
  (setq *rp:cwarned* nil))

;; Tile values as an override list (+ values handed over by the RDP dialog)
(defun rp:cdlg-ov () (append (mapcar '(lambda (k) (cons k (get_tile k))) *rp:ckeys*) *rp:cpar*))

(defun rp:cdlg-width (/ v)
  (if (and *rp:cpar* (setq v (assoc "width" *rp:cpar*)) (rp:dist (cdr v))) (rp:dist (cdr v)) (rp:cn "width")))

(defun rp:join2 (lst sep / s) (setq s "") (foreach x lst (setq s (if (= s "") x (strcat s sep x)))) s)

(defun rp:cdlg-check (/ chk pl)
  (setq *rp:cov* (rp:cdlg-ov)
        chk (rp:corr-check (rp:cdlg-width)))
  (if (not (car chk))
    (progn
      (setq pl (rp:lane-plan (rp:cdlg-width)))
      (set_tile "m1" (if (nth 6 pl) (car (nth 6 pl))
                       (strcat "Road width from the RDP dialog : " (rtos (car pl) 2 2) " m (no lane lines).")))
      (set_tile "m2" (if (cadr chk) (strcat "Warnings: " (rp:join2 (cadr chk) " | ")) "No warnings."))
      (set_tile "m3" (strcat "Result: " (rp:corr-summary) ",  road width " (rtos (car pl) 2 2) " m.")))
    (progn
      (set_tile "m1" (strcat "Errors: " (rp:join2 (car chk) " | ")))
      (set_tile "m2" "") (set_tile "m3" "")))
  (setq *rp:cov* nil)
  chk)

(defun rp:cdlg-accept (/ chk)
  (setq chk (rp:cdlg-check))
  (cond
    ((car chk) (set_tile "error" (car (car chk))))
    ((and (cadr chk) (not *rp:cwarned*))
     (setq *rp:cwarned* T)
     (set_tile "error" (strcat (car (cadr chk)) (if (cdr (cadr chk)) " (more above)" "") "  -  press OK again to accept.")))
    (T
     (foreach k *rp:ckeys* (rp:set k (get_tile k)))
     (foreach w (cadr chk) (princ (strcat "\n  Corridor warning: " w)))
     (done_dialog 1))))

;; info = first line of the dialog. Returns 'ok / 'cancel / 'fail
(defun rp:cdialog (info / fn f id res)
  (setq fn (vl-filename-mktemp "roadcorr.dcl") *rp:cwarned* nil)
  (if (setq f (open fn "w"))
    (progn
      (foreach l *rp:cdcl* (write-line l f))
      (close f)
      (setq id (load_dialog fn))
      (if (and id (not (minusp id)) (new_dialog "roadcorr" id))
        (progn
          (set_tile "info" info)
          (rp:fill "ccarr"  '("Single carriageway" "Dual carriageway"))
          (rp:fill "clmode" '("From road width (no lane lines)" "Manual lane count" "Automatic lane count"))
          (rp:fill "cmed"   '("No median" "Flush median (painted, hatched)" "Raised median (kerbed)"))
          (rp:fill "cdrt"   '("Open channel (trapezoidal)" "Covered U-channel" "Stormwater pipe"))
          (rp:fill "cpat"   '("Interlocking paver (I-shape)" "Herringbone paver (AR-HBONE)" "Other pattern"))
          (foreach k *rp:ckeys* (set_tile k (rp:cv k)))
          (rp:cdlg-modes)
          (rp:cdlg-check)
          (foreach k '("ccarr" "clmode" "cmed" "cswl" "cswr" "cwkl" "cwkr" "cdrl" "cdrr" "cutl" "cutr" "cpav" "cpat")
            (action_tile k "(rp:cdlg-modes)"))
          (action_tile "check"  "(rp:cdlg-check)")
          (action_tile "accept" "(rp:cdlg-accept)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq res (if (= (start_dialog) 1) 'ok 'cancel)))
        (setq res 'fail))
      (if (and id (not (minusp id))) (unload_dialog id))
      (vl-file-delete fn))
    (setq res 'fail))
  res)

;; Button in the RDP dialog
(defun rp:main-corr (/ r)
  (setq *rp:cpar* (list (cons "width" (get_tile "width")) (cons "ctype" (get_tile "ctype")) (cons "bwid" (get_tile "bwid"))))
  (setq r (rp:cdialog "Settings for new roads built with RDP (left / right seen looking along the centre line)."))
  (setq *rp:cpar* nil)
  (rp:main-corr-tiles)
  r)

(defun rp:main-corr-tiles (/ pl)
  (setq pl (rp:lane-plan (if (rp:dist (get_tile "width")) (rp:dist (get_tile "width")) (rp:num "width"))))
  (set_tile "csum" (strcat (rp:corr-summary)
                           (if (= (rp:val "clmode") "0") "" (strcat "  ->  road width " (rtos (car pl) 2 2) " m"))))
  (mode_tile "width" (if (= (rp:val "clmode") "1") 1 0)))

;;----------------------------------------------------------------------------
;;  Alignment checks : short segments, sharp bends without a curve, radius
;;  smaller than half the road, self-intersection.  Returns a list of texts.
;;----------------------------------------------------------------------------
(defun rp:seg-list (pts bul closed / n i out p0 p1 b th c ch r ln)
  (setq n (length pts) i 0)
  (repeat (if closed n (1- n))
    (setq p0 (nth i pts) p1 (nth (rem (1+ i) n) pts) b (nth i bul)
          ch (distance p0 p1) c (angle p0 p1))
    (if (> (abs b) 1e-9)
      (setq th (* 4.0 (atan b))
            r  (if (> ch 1e-12) (/ ch (* 2.0 (sin (* 0.5 (abs th))))) 0.0)
            ln (* r (abs th))
            out (cons (list p0 p1 b ln (- c (* 0.5 th)) (+ c (* 0.5 th)) r) out))
      (setq out (cons (list p0 p1 0.0 ch c c 0.0) out)))
    (setq i (1+ i)))
  (reverse out))

;; chords of a segment (arcs as 8 chords)
(defun rp:seg-chords (s / p0 p1 b th c r ctr a0 k out)
  (setq p0 (car s) p1 (cadr s) b (caddr s))
  (if (< (abs b) 1e-9)
    (list (list p0 p1))
    (progn
      (setq th  (* 4.0 (atan b)) r (nth 6 s)
            c   (angle p0 p1)
            ctr (polar p0 (+ (- c (* 0.5 th)) (if (> b 0) (* 0.5 pi) (* -0.5 pi))) r)
            a0  (angle ctr p0) k 1 out nil)
      (repeat 8
        (setq out (cons (list (polar ctr (+ a0 (* th (/ (float (1- k)) 8.0))) r)
                              (polar ctr (+ a0 (* th (/ (float k) 8.0))) r))
                        out)
              k (1+ k)))
      (reverse out))))

(defun rp:angdiff (a b / d)
  (setq d (rem (- b a) (* 2.0 pi)))
  (if (> d pi) (setq d (- d (* 2.0 pi))))
  (if (< d (- pi)) (setq d (+ d (* 2.0 pi))))
  d)

(defun rp:bbox-hit (ca cb / ax1 ax2 ay1 ay2 bx1 bx2 by1 by2)
  (setq ax1 (min (car (car ca)) (car (cadr ca))) ax2 (max (car (car ca)) (car (cadr ca)))
        ay1 (min (cadr (car ca)) (cadr (cadr ca))) ay2 (max (cadr (car ca)) (cadr (cadr ca)))
        bx1 (min (car (car cb)) (car (cadr cb))) bx2 (max (car (car cb)) (car (cadr cb)))
        by1 (min (cadr (car cb)) (cadr (cadr cb))) by2 (max (cadr (car cb)) (cadr (cadr cb))))
  (and (<= bx1 (+ ax2 1e-9)) (<= ax1 (+ bx2 1e-9)) (<= by1 (+ ay2 1e-9)) (<= ay1 (+ by2 1e-9))))

;; pts / bul = vertex list, closed flag, fac, hw (drawing units), st start chainage
(defun rp:cl-check (pts bul closed fac hw st / segs n i j s s2 out d dv ch ca cb hit ip ns)
  (setq segs (rp:seg-list pts bul closed) n (length segs) d 0.0 i 0)
  (foreach s segs
    (if (< (nth 3 s) (* 1.0 fac))
      (setq out (cons (strcat "very short segment (" (rtos (/ (nth 3 s) fac) 2 3) " m) at CH " (rp:chfmt (+ st (/ d fac)))) out)))
    (if (and (> (abs (caddr s)) 1e-9) (< (nth 6 s) hw))
      (setq out (cons (strcat "curve at CH " (rp:chfmt (+ st (/ d fac))) " has R " (rtos (/ (nth 6 s) fac) 2 2)
                              " m, smaller than half the road width") out)))
    (setq d (+ d (nth 3 s)))
    (if (or (< (1+ i) n) closed)
      (progn
        (setq s2 (nth (rem (1+ i) n) segs)
              dv (abs (rp:angdiff (nth 5 s) (nth 4 s2))))
        (if (and (> dv (/ pi 360.0)) (or (< (1+ i) n) closed))
          (setq out (cons (strcat "sharp bend of " (rtos (* 180.0 (/ dv pi)) 2 1) " deg at CH "
                                  (rp:chfmt (+ st (/ d fac))) " with no curve") out)))))
    (setq i (1+ i)))
  ;; self-intersection (non-adjacent segments)
  (setq i 0 ns nil)
  (while (and (< i n) (not hit))
    (setq j (+ i 2))
    (while (and (< j n) (not hit))
      (if (not (and closed (= i 0) (= j (1- n))))
        (foreach ca (rp:seg-chords (nth i segs))
          (foreach cb (rp:seg-chords (nth j segs))
            (if (and (not hit) (rp:bbox-hit ca cb) (setq ip (inters (car ca) (cadr ca) (car cb) (cadr cb) T)))
              (setq hit ip)))))
      (setq j (1+ j)))
    (setq i (1+ i)))
  (if hit
    (setq out (cons (strcat "SELF-INTERSECTION: the centre line crosses itself near E " (rtos (/ (car hit) fac) 2 3)
                            "  N " (rtos (/ (cadr hit) fac) 2 3)) out)))
  (reverse out))

;; Checks on the centre line before a build. Manual radius is filleted here.
;; Returns T to go on, nil to stop.
(defun rp:cl-ok (cl rc fac hw / obj pd msgs go)
  (if (> rc 0.0)
    (progn (setvar "FILLETRAD" rc) (command "_.FILLET" "_P" cl)))
  (setq obj  (vlax-ename->vla-object cl)
        pd   (rp:pldata obj)
        msgs (rp:cl-check (car pd) (cadr pd) (vlax-curve-isClosed obj) fac hw (rp:num "chst"))
        go   T)
  (foreach m msgs (princ (strcat "\n  Alignment check: " m)))
  (if (and (> rc 0.0) (vl-some '(lambda (m) (wcmatch m "sharp bend*")) msgs))
    (princ "\n  (the manual radius did not fit at those bends - segments too short for the radius)"))
  (if (and (not *rp:live-run*) (not *rp:replay*) (vl-some '(lambda (m) (wcmatch m "SELF-INTERSECTION*")) msgs))
    (progn
      (initget "Yes No")
      (setq go (= (getkword "\nThe centre line crosses itself. Build the road anyway? [Yes/No] <No>: ") "Yes"))))
  go)

;;----------------------------------------------------------------------------
;;  Civil 3D alignment -> LWPOLYLINE.  Explodes a COPY of the alignment and
;;  joins its lines / arcs; falls back to sampling by station (PointLocation).
;;  *rp:c3dsta* = start station when it can be read.  NOT verified in
;;  Civil 3D in the development environment - see the user guide.
;;----------------------------------------------------------------------------
(defun rp:c3d-align (e / o cp mark new ss pl sta sta2 x pts ee nn r)
  (setq o (vlax-ename->vla-object e) *rp:c3dsta* nil)
  (setq sta (vl-catch-all-apply 'vlax-get-property (list o 'StartingStation)))
  (if (and (not (vl-catch-all-error-p sta)) (numberp sta)) (setq *rp:c3dsta* sta))
  (setq mark (entlast)
        cp   (vl-catch-all-apply 'vla-Copy (list o)))
  (if (and cp (not (vl-catch-all-error-p cp)))
    (progn
      (command "_.EXPLODE" (vlax-vla-object->ename cp))
      (while (> (getvar "CMDACTIVE") 0) (command ""))
      (setq new (rp:since mark) ss (ssadd))
      (foreach x new
        (if (entget x)
          (if (wcmatch (cdr (assoc 0 (entget x))) "LINE,ARC,LWPOLYLINE")
            (ssadd x ss)
            (entdel x))))
      (cond
        ((= (sslength ss) 0))
        ((and (= (sslength ss) 1) (= (cdr (assoc 0 (entget (ssname ss 0)))) "LWPOLYLINE"))
         (setq pl (ssname ss 0)))
        (T
         (setvar "PEDITACCEPT" 1)
         (command "_.PEDIT" "_M" ss "" "_J" "0.001" "")
         (setq pl (entlast))
         (if (/= (cdr (assoc 0 (entget pl))) "LWPOLYLINE") (setq pl nil))))))
  (if (and (null pl) *rp:c3dsta*)
    (progn
      (setq sta2 (vl-catch-all-apply 'vlax-get-property (list o 'EndingStation)) x *rp:c3dsta*)
      (if (and (not (vl-catch-all-error-p sta2)) (numberp sta2))
        (progn
          (while (<= x sta2)
            (setq ee nil nn nil
                  r  (vl-catch-all-apply 'vlax-invoke-method (list o 'PointLocation x 0.0 'ee 'nn)))
            (if (and (not (vl-catch-all-error-p r)) (numberp ee) (numberp nn)) (setq pts (cons (list ee nn) pts)))
            (setq x (if (and (< x sta2) (> (+ x 1.0) sta2)) sta2 (+ x 1.0))))
          (if (cdr pts)
            (progn
              (setq pl (vlax-vla-object->ename (rp:mkpl (mapcar '(lambda (p) (list p 0.0)) (reverse pts)) "0" 0.0 nil)))
              (princ "\n  Alignment sampled every 1 m - curves become short straights (use LandXML, RDLXI, for exact arcs).")))))))
  (if pl
    (princ (strcat "\n  Civil 3D alignment converted to a polyline"
                   (if *rp:c3dsta* (strcat ", start station " (rtos *rp:c3dsta* 2 3)) "") "."))
    (princ "\n  The Civil 3D alignment could not be converted. Export it as LandXML and use RDLXI, or explode it to a polyline."))
  pl)

;;----------------------------------------------------------------------------
;;  LandXML 1.2 alignment export / import
;;----------------------------------------------------------------------------
(defun rp:xml-esc (s)
  (foreach p '(("&" . "&amp;") ("<" . "&lt;") (">" . "&gt;") ("\"" . "&quot;"))
    (setq s (rp:str-replace s (car p) (cdr p))))
  s)

(defun rp:str-replace (s old new / i out)
  (setq out "")
  (while (setq i (vl-string-search old s))
    (setq out (strcat out (substr s 1 i) new) s (substr s (+ i 1 (strlen old)))))
  (strcat out s))

(defun rp:lx-pt (p fac) (strcat (rtos (/ (cadr p) fac) 2 4) " " (rtos (/ (car p) fac) 2 4)))

(defun rp:lx-date (/ cd s)
  (setq s (rtos (getvar "CDATE") 2 6))
  (list (strcat (substr s 1 4) "-" (substr s 5 2) "-" (substr s 7 2))
        (strcat (substr s 10 2) ":" (substr s 12 2) ":" (substr s 14 2))))

;; Write the centre line e as a LandXML 1.2 alignment. Returns the path or nil
(defun rp:lx-export (e path / data fac obj pd pts bul n i p0 p1 b d0 d1 st nm f th ch r ctr dt seg)
  (setq data (rp:xget e)
        fac  (if (> (atof (rp:xv "FAC" data)) 0.0) (atof (rp:xv "FAC" data)) (if (= (rp:val "units") "1") 1000.0 1.0))
        obj  (vlax-ename->vla-object e)
        pd   (rp:pldata obj) pts (car pd) bul (cadr pd) n (length pts)
        st   (if data (atof (rp:xv "CHST" data)) 0.0)
        nm   (if (and data (/= (rp:xv "NAME" data) "")) (rp:xv "NAME" data) "ALIGNMENT")
        dt   (rp:lx-date))
  (if (setq f (open path "w"))
    (progn
      (foreach l (list "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                       (strcat "<LandXML xmlns=\"http://www.landxml.org/schema/LandXML-1.2\" "
                               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                               "xsi:schemaLocation=\"http://www.landxml.org/schema/LandXML-1.2 http://www.landxml.org/schema/LandXML-1.2/LandXML-1.2.xsd\" "
                               "version=\"1.2\" date=\"" (car dt) "\" time=\"" (cadr dt) "\" readOnly=\"false\" language=\"English\">")
                       "  <Units>"
                       "    <Metric areaUnit=\"squareMeter\" linearUnit=\"meter\" volumeUnit=\"cubicMeter\" temperatureUnit=\"celsius\" pressureUnit=\"milliBars\" angularUnit=\"decimal degrees\" directionUnit=\"decimal degrees\"/>"
                       "  </Units>"
                       (strcat "  <Project name=\"" (rp:xml-esc (vl-filename-base (getvar "DWGNAME"))) "\"/>")
                       (strcat "  <Application name=\"RoadPro\" desc=\"Road builder for AutoCAD - Developed by https://www.exceltokml.com/\" manufacturer=\"exceltokml.com\" version=\"" *rp:ver* "\"/>")
                       "  <Alignments name=\"RoadPro\">"
                       (strcat "    <Alignment name=\"" (rp:xml-esc nm) "\" length=\""
                               (rtos (/ (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj)) fac) 2 4)
                               "\" staStart=\"" (rtos st 2 4) "\" desc=\"RoadPro centre line\">")
                       "      <CoordGeom>")
        (write-line l f))
      (setq i 0)
      (repeat (if (vlax-curve-isClosed obj) n (1- n))
        (setq p0 (nth i pts) p1 (nth (rem (1+ i) n) pts) b (nth i bul)
              d0 (vlax-curve-getDistAtParam obj i) d1 (vlax-curve-getDistAtParam obj (1+ i)))
        (if (> (distance p0 p1) 1e-9)
          (if (< (abs b) 1e-9)
            (write-line (strcat "        <Line staStart=\"" (rtos (+ st (/ d0 fac)) 2 4) "\" length=\"" (rtos (/ (- d1 d0) fac) 2 4)
                                "\"><Start>" (rp:lx-pt p0 fac) "</Start><End>" (rp:lx-pt p1 fac) "</End></Line>") f)
            (progn
              (setq th  (* 4.0 (atan b))
                    ch  (distance p0 p1)
                    r   (/ ch (* 2.0 (sin (* 0.5 (abs th)))))
                    ctr (polar p0 (+ (- (angle p0 p1) (* 0.5 th)) (if (> b 0) (* 0.5 pi) (* -0.5 pi))) r))
              (write-line (strcat "        <Curve rot=\"" (if (> b 0) "ccw" "cw") "\" crvType=\"arc\" radius=\"" (rtos (/ r fac) 2 4)
                                  "\" length=\"" (rtos (/ (- d1 d0) fac) 2 4) "\" delta=\"" (rtos (* 180.0 (/ (abs th) pi)) 2 6)
                                  "\" staStart=\"" (rtos (+ st (/ d0 fac)) 2 4) "\"><Start>" (rp:lx-pt p0 fac)
                                  "</Start><Center>" (rp:lx-pt ctr fac) "</Center><End>" (rp:lx-pt p1 fac) "</End></Curve>") f))))
        (setq i (1+ i)))
      (foreach l '("      </CoordGeom>" "    </Alignment>" "  </Alignments>" "</LandXML>") (write-line l f))
      (close f)
      path)))

;; ---- tiny XML helpers (enough for LandXML alignments) ----
(defun rp:xml-attr (el nm / i j)
  (if (setq i (vl-string-search (strcat " " nm "=\"") el))
    (progn (setq i (+ i (strlen nm) 3) j (vl-string-search "\"" el i)) (substr el (1+ i) (- j i)))))

(defun rp:xml-child (el nm / i j k)
  (if (setq i (vl-string-search (strcat "<" nm) el))
    (progn
      (setq j (vl-string-search ">" el i)
            k (vl-string-search (strcat "</" nm ">") el j))
      (if (and j k) (substr el (+ j 2) (- k j 1))))))

(defun rp:xml-nums (s / out v)
  (while (and s (/= (setq s (vl-string-trim " \t\n" s)) ""))
    (setq v (vl-string-search " " s))
    (setq out (cons (atof (if v (substr s 1 v) s)) out) s (if v (substr s (+ v 2)) nil)))
  (reverse out))

(defun rp:lx-xy (s fac / v) (setq v (rp:xml-nums s)) (if (cadr v) (list (* fac (cadr v)) (* fac (car v)))))

;; next element of the CoordGeom string g from position p : (tag start end) or nil
(defun rp:lx-next (g p / best tag i j)
  (foreach tg '("Line" "Curve" "Spiral")
    (if (and (setq i (vl-string-search (strcat "<" tg) g p)) (or (null best) (< i (car best))))
      (setq best (list i tg))))
  (if best
    (progn
      (setq tag (cadr best) i (car best)
            j   (vl-string-search (strcat "</" tag ">") g i))
      (if (null j) (setq j (vl-string-search "/>" g i)))
      (list tag i (+ j (strlen tag) 3)))))

;; Read all alignments of a LandXML file as polylines. Returns ((ename name sta) ...)
(defun rp:lx-import (path / f s l fac a i j al nm sta g p el tg pts bul st en c rot a0 a1 sw warn out lay o)
  (setq fac (if (= (rp:val "units") "1") 1000.0 1.0) s "")
  (if (setq f (open path "r"))
    (progn
      (while (setq l (read-line f)) (setq s (strcat s l " ")))
      (close f)
      (if (and (vl-string-search "linearUnit=\"foot\"" s) (not (vl-string-search "linearUnit=\"meter\"" s)))
        (setq warn (cons "the file is in feet - coordinates are read as they are" warn)))
      (rp:mklayer "ROAD-LANDXML" 140 nil 35)
      (setq p 0)
      (while (setq i (vl-string-search "<Alignment " s p))
        (setq j  (vl-string-search "</Alignment>" s i)
              al (substr s (1+ i) (- (+ j 12) i))
              p  (+ j 12)
              nm (rp:xml-attr al "name")
              sta (atof (if (rp:xml-attr al "staStart") (rp:xml-attr al "staStart") "0"))
              g  (rp:xml-child al "CoordGeom")
              pts nil bul nil a 0)
        (while (and g (setq el (rp:lx-next g a)))
          (setq tg (car el) a (caddr el)
                el (substr g (1+ (cadr el)) (- (caddr el) (cadr el)))
                st (rp:lx-xy (rp:xml-child el "Start") fac)
                en (rp:lx-xy (rp:xml-child el "End") fac))
          (if (and st en)
            (progn
              (if (null pts)
                (setq pts (list st) bul (list 0.0))
                (if (> (distance (car pts) st) (* 0.001 fac))
                  (setq warn (cons (strcat nm ": gap of " (rtos (/ (distance (car pts) st) fac) 2 3) " m between elements - joined") warn)
                        pts (cons st pts) bul (cons 0.0 bul))))
              (cond
                ((= tg "Curve")
                 (setq c   (rp:lx-xy (rp:xml-child el "Center") fac)
                       rot (rp:xml-attr el "rot"))
                 (if c
                   (progn
                     (setq a0 (angle c st) a1 (angle c en)
                           sw (if (= rot "cw")
                                (- (rem (+ (- a0 a1) (* 4.0 pi)) (* 2.0 pi)))
                                (rem (+ (- a1 a0) (* 4.0 pi)) (* 2.0 pi))))
                     (setq bul (cons (/ (sin (* 0.25 sw)) (cos (* 0.25 sw))) (cdr bul))))))
                ((= tg "Spiral")
                 (setq warn (cons (strcat nm ": spiral replaced by a straight chord") warn))))
              (setq pts (cons en pts) bul (cons 0.0 bul)))))
        (if (cdr pts)
          (progn
            (setq o (rp:mkpl (mapcar 'list (reverse pts) (reverse bul)) "ROAD-LANDXML" 0.0 nil))
            (setq out (cons (list (vlax-vla-object->ename o) nm sta) out))))))
    (setq warn (cons (strcat "cannot open " path) warn)))
  (foreach w (reverse warn) (princ (strcat "\n  LandXML: " w)))
  (reverse out))

;;----------------------------------------------------------------------------
;;  Radius edit and rebuild
;;----------------------------------------------------------------------------
(defun rp:subst-nth (i v lst / k out)
  (setq k 0)
  (foreach x lst (setq out (cons (if (= k i) v x) out) k (1+ k)))
  (reverse out))

;; Remove zero-length segments : vertex k+1 equal to vertex k
(defun rp:pl-clean (pts bul / out ob k p q)
  (setq k 0)
  (while pts
    (setq p (car pts) q (cadr pts))
    (if (and q (< (distance p q) 1e-7))
      (setq pts (cdr pts) bul (cons (cadr bul) (cddr bul)))   ; drop vertex k+1, keep the following bulge
      (setq out (cons p out) ob (cons (car bul) ob) pts (cdr pts) bul (cdr bul))))
  (list (reverse out) (reverse ob)))

;; Re-fit arc segment i of a vertex list to radius r between its two tangents.
;; Returns (pts bul) or an error text.
(defun rp:fit-radius (pts bul closed i r / n ia ic id pa pb pc pd ip th tl la lb u1 u2 tn crs)
  (setq n (length pts) ia (1- i) ic (1+ i) id (+ i 2))
  (if closed (setq ia (rem (+ ia n) n) ic (rem ic n) id (rem id n)))
  (cond
    ((or (< i 0) (>= i (length bul)) (< (abs (nth i bul)) 1e-9)) "This segment is a straight line, not a curve.")
    ((or (< ia 0) (>= id n))
     "The curve is at the start or end of the centre line - it needs a straight on both sides.")
    ((> (abs (nth ia bul)) 1e-9) "The curve joins the curve before it directly (compound / reverse curve) - not supported.")
    ((> (abs (nth ic bul)) 1e-9) "The curve joins the curve after it directly (compound / reverse curve) - not supported.")
    ((<= r 0.0) "The radius must be greater than zero.")
    (T
     (setq pa (nth ia pts) pb (nth i pts) pc (nth ic pts) pd (nth id pts)
           ip (inters pa pb pc pd nil)
           th (* 4.0 (atan (abs (nth i bul)))))
     (if (null ip)
       "The two tangents are parallel - the curve cannot be fitted."
       (progn
         ;; the deflection is taken from the two tangents, so the new curve is
         ;; always tangent to both straights (even if the old one was not)
         (setq u1 (rp:unitv (list (- (car ip) (car pa)) (- (cadr ip) (cadr pa))))
               u2 (rp:unitv (list (- (car pd) (car ip)) (- (cadr pd) (cadr ip))))
               crs (- (* (car u1) (cadr u2)) (* (cadr u1) (car u2)))
               th (abs (rp:angdiff (angle '(0.0 0.0) u1) (angle '(0.0 0.0) u2)))
               tn (/ (sin (* 0.5 th)) (cos (* 0.5 th)))
               tl (* r tn)
               la (distance pa ip)
               lb (distance ip pd))
         (cond
           ((< th 1e-6) "The straights on both sides are in line - there is no bend to fit a curve to.")
           ((/= (if (> crs 0.0) 1 -1) (if (> (nth i bul) 0.0) 1 -1))
            "The curve does not turn the same way as its tangents - edit the centre line by hand.")
           ((> tl (+ la 1e-6))
            (strcat "Radius too large: the curve would run back past the previous point. Largest radius here: "
                    (rtos (/ la tn) 2 3) " (drawing units)."))
           ((> tl (+ lb 1e-6))
            (strcat "Radius too large: the curve would run past the next point. Largest radius here: "
                    (rtos (/ lb tn) 2 3) " (drawing units)."))
           (T
            (setq pts (rp:subst-nth i  (list (- (car ip) (* tl (car u1))) (- (cadr ip) (* tl (cadr u1)))) pts)
                  pts (rp:subst-nth ic (list (+ (car ip) (* tl (car u2))) (+ (cadr ip) (* tl (cadr u2)))) pts)
                  bul (rp:subst-nth i (* (if (> crs 0.0) 1.0 -1.0) (/ (sin (* 0.25 th)) (cos (* 0.25 th)))) bul))
            (rp:pl-clean pts bul))))))))

;; Write vertices and bulges back to a polyline object
(defun rp:pl-set (obj pts bul / fl i)
  (foreach p pts (setq fl (append fl (list (float (car p)) (float (cadr p))))))
  (vla-put-Coordinates obj
    (vlax-make-variant (vlax-safearray-fill (vlax-make-safearray vlax-vbDouble (cons 0 (1- (length fl)))) fl)))
  (setq i 0)
  (foreach b bul (vla-SetBulge obj i b) (setq i (1+ i)))
  (princ))

(defun rp:keep-layer-p (en / ly)
  (setq ly (strcase (cdr (assoc 8 (entget en)))))
  (or (= ly "ROAD-REPORT") (wcmatch ly "ROAD-XSEC*") (and (= ly "ROAD-CL") (rp:xget en))))

;; Objects of road e (not its CL, not report tables / sections, not other CLs)
(defun rp:road-objects (e / obj hs en out data fac hw dmax ss i p q ly bb mn mx)
  (setq obj (vlax-ename->vla-object e)
        hs  (append (vlax-ldata-get obj "ROADPRO_ALL") (vlax-ldata-get obj "ROADPRO_MKMAN") (vlax-ldata-get obj "ROADPRO_CORR")))
  (if hs
    (foreach h hs
      (if (and (setq en (handent h)) (entget en) (not (eq en e)) (not (rp:keep-layer-p en)) (not (member en out)))
        (setq out (cons en out))))
    (progn
      ;; road built before v3.4 : objects on ROAD-* layers close to the centre line
      (setq data (rp:xget e)
            fac  (if (> (atof (rp:xv "FAC" data)) 0.0) (atof (rp:xv "FAC" data)) 1.0)
            hw   (* 0.5 fac (atof (rp:xv "W" data)))
            dmax (+ hw (* fac (+ (atof (rp:xv "BGAP" data)) (atof (rp:xv "BWID" data)) 20.0)))
            ss   (ssget "_X" '((8 . "ROAD-*")))
            i    0)
      (if ss
        (repeat (sslength ss)
          (setq en (ssname ss i) i (1+ i))
          (if (and (not (eq en e)) (not (rp:keep-layer-p en)))
            (progn
              (setq bb (vl-catch-all-apply 'vla-GetBoundingBox (list (vlax-ename->vla-object en) 'mn 'mx)))
              (if (not (vl-catch-all-error-p bb))
                (progn
                  (setq mn (vlax-safearray->list mn) mx (vlax-safearray->list mx)
                        p  (list (* 0.5 (+ (car mn) (car mx))) (* 0.5 (+ (cadr mn) (cadr mx))) (vla-get-Elevation obj))
                        q  (vlax-curve-getClosestPointTo e p))
                  (if (< (distance (rp:p2 p) (rp:p2 q)) dmax) (setq out (cons en out)))))))))
      (if out
        (progn
          (initget "Yes Select No")
          (setq p (getkword (strcat "\nRoad built before v3.4: " (itoa (length out)) " objects within "
                                    (rtos (/ dmax fac) 2 1) " m of the centre line will be replaced. [Yes/Select/No] <Yes>: ")))
          (cond ((= p "No") (setq out nil))
                ((= p "Select")
                 (setq out nil ss (ssget '((8 . "ROAD-*"))) i 0)
                 (if ss (repeat (sslength ss) (setq en (ssname ss i) i (1+ i))
                          (if (and (not (eq en e)) (not (rp:keep-layer-p en))) (setq out (cons en out)))))))))))
  out)

;; Settings of an older road (no stored snapshot) : current settings + road data
(defun rp:snapshot-from-xdata (data / s fac)
  (setq s (rp:snapshot) fac (atof (rp:xv "FAC" data)))
  (foreach p (list (cons "rname" (rp:xv "NAME" data)) (cons "width" (rp:xv "W" data))
                   (cons "chst" (rp:xv "CHST" data)) (cons "chint" (rp:xv "CHINT" data))
                   (cons "blen" (rp:xv "BLEN" data)) (cons "bwid" (rp:xv "BWID" data)) (cons "bgap" (rp:xv "BGAP" data))
                   (cons "bl" (rp:xv "EL" data)) (cons "br" (rp:xv "ER" data)) (cons "etype" (rp:xv "ETYPE" data))
                   (cons "ctype" (rp:xv "CTYPE" data)) (cons "speed" (rp:xv "SPEED" data)) (cons "twoway" (rp:xv "TWOWAY" data))
                   (cons "cmark" (rp:xv "CMARK" data)) (cons "sset" (rp:xv "SSET" data))
                   (cons "endst" (cond ((= (rp:xv "ENDS" data) "-") "2") ((/= (rp:xv "ENDS" data) "") (rp:xv "ENDS" data)) (T "0")))
                   (cons "endfn" (cond ((= (rp:xv "ENDF" data) "-") "2") ((/= (rp:xv "ENDF" data) "") (rp:xv "ENDF" data)) (T "0")))
                   (cons "units" (if (= fac 1000.0) "1" "0"))
                   '("ccarr" . "0") '("clmode" . "0") '("cmed" . "0")
                   '("cswl" . "0") '("cswr" . "0") '("cwkl" . "0") '("cwkr" . "0")
                   '("cdrl" . "0") '("cdrr" . "0") '("cutl" . "0") '("cutr" . "0"))
    (if (/= (cdr p) "") (setq s (cons p (vl-remove-if '(lambda (x) (= (car x) (car p))) s)))))
  s)

;; rp:rebuild : see the v3.5 operation log section (replays widenings, tapers, junctions, roundabouts)

(defun rp:pick-road (msg / sel)
  (while (and (setq sel (entsel msg)) (not (rp:xget (car sel))))
    (princ "\n  No RoadPro data on this object - select the centre line of a RoadPro road."))
  sel)

;;----------------------------------------------------------------------------
;;  Commands (v3.4)
;;----------------------------------------------------------------------------
;; Edit the radius of a curve after the road is built, then rebuild the road
(defun c:ROADEDITRADIUS (/ sel e obj data fac hw st curves cp d k i bd dd c r all tg pd pts bul res bad cv ix)
  (rp:start) (rp:space) (rp:world) (rp:linetypes) (rp:layers)
  (if (setq sel (rp:pick-road "\nSelect the road centre line ON the curve to change (layer ROAD-CL): "))
    (progn
      (setq e    (car sel)
            obj  (vlax-ename->vla-object e)
            data (rp:xget e)
            fac  (if (> (atof (rp:xv "FAC" data)) 0.0) (atof (rp:xv "FAC" data)) 1.0)
            hw   (* 0.5 fac (atof (rp:xv "W" data)))
            st   (atof (rp:xv "CHST" data))
            *rp:len* (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
            curves (rp:curves obj))
      (if (null curves)
        (princ "\n  This road has no curves (arc segments) to edit.")
        (progn
          (setq cp (vlax-curve-getClosestPointTo obj (trans (cadr sel) 1 0))
                d  (vlax-curve-getDistAtPoint obj cp)
                i  0 k 1 bd 1e99)
          (foreach c curves
            (setq i  (1+ i)
                  dd (cond ((< d (car c)) (- (car c) d)) ((> d (cadr c)) (- d (cadr c))) (T 0.0)))
            (if (< dd bd) (setq bd dd k i)))
          (setq c (nth (1- k) curves))
          (princ (strcat "\n  Curve C" (itoa k) " : R (CL) = " (rtos (/ (nth 2 c) fac) 2 3) " m,  deflection "
                         (rp:dms (nth 3 c) T) ",  CH " (rp:chfmt (+ st (/ (car c) fac))) " - " (rp:chfmt (+ st (/ (cadr c) fac)))))
          (initget 6 "Inner All")
          (setq r (getdist (strcat "\nNew radius at the CENTRE LINE for C" (itoa k) " [Inner edge/All curves] <"
                                   (rtos (/ (nth 2 c) fac) 2 3) ">: ")))
          (setq tg (list k))
          (cond
            ((= r "All")
             (setq tg nil i 0)
             (foreach c curves (setq i (1+ i) tg (cons i tg)))
             (initget 7)
             (setq r (getdist "\nNew radius at the CENTRE LINE for ALL curves: ")))
            ((= r "Inner")
             (initget 7)
             (if (setq r (getdist (strcat "\nNew radius at the INNER EDGE (kerb line) for C" (itoa k) ": ")))
               (setq r (+ r (/ hw fac)))))
            ((null r) (setq r (/ (nth 2 c) fac))))
          (cond
            ((null r) (princ "\n  Nothing changed."))
            ((<= (* r fac) hw)
             (alert (strcat "The radius must be larger than half the road width (" (rtos (/ hw fac) 2 2) " m).\n\nNothing changed.")))
            (T
             (setq pd (rp:pldata obj) pts (car pd) bul (cadr pd))
             ;; last curve first so vertex numbers stay valid
             (foreach ix (vl-sort tg '>)
               (if (not bad)
                 (progn
                   (setq cv (nth (1- ix) curves)
                         i  (fix (vlax-curve-getParamAtDist obj (* 0.5 (+ (car cv) (cadr cv)))))
                         res (rp:fit-radius pts bul (vlax-curve-isClosed obj) i (* r fac)))
                   (if (= (type res) 'STR)
                     (setq bad (strcat "Curve C" (itoa ix) ": " res))
                     (setq pts (car res) bul (cadr res))))))
             (if bad
               (alert (strcat bad "\n\nNothing changed."))
               (progn
                 (if (< (* r fac) (+ hw (* fac (+ (atof (rp:xv "BGAP" data)) (atof (rp:xv "BWID" data))))))
                   (princ "\n  Warning: the edge treatment on the inside of the bend is tighter than the radius."))
                 (rp:pl-set obj pts bul)
                 (princ (strcat "\n  Radius set to " (rtos r 2 3) " m at the centre line for "
                                (if (cdr tg) (strcat (itoa (length tg)) " curves") (strcat "C" (itoa k))) "."))
                 (if (not (rp:rebuild e nil))
                   (princ "\n  The centre line was changed but the road was not rebuilt - run RDB (ROADREBUILD) when ready."))))))))))
  (rp:finish))

;; Rebuild a road after its centre line was edited (grips, Properties, PEDIT ...)
(defun c:ROADREBUILD (/ sel)
  (rp:start) (rp:space) (rp:world) (rp:linetypes) (rp:layers)
  (if (setq sel (rp:pick-road "\nSelect the edited road centre line (layer ROAD-CL): "))
    (progn
      (if (rp:cl-tangentize (vlax-ename->vla-object (car sel)))
        (princ "\n  Curves fitted again so they stay tangent to the straights."))
      (rp:rebuild (car sel) nil)))
  (rp:finish))

;; Change lanes / median / sidewalks / drains / utilities of an existing road
(defun c:ROADCORRIDOR (/ sel e obj data snap old new pl0 pl1 fac res w)
  (rp:start) (rp:space) (rp:world) (rp:linetypes) (rp:layers)
  (if (setq sel (rp:pick-road "\nSelect the road centre line (layer ROAD-CL): "))
    (progn
      (setq e (car sel) obj (vlax-ename->vla-object e) data (rp:xget e)
            snap (vlax-ldata-get obj "ROADPRO_SET"))
      (if (null snap) (setq snap (rp:snapshot-from-xdata data)))
      (setq w (atof (cdr (assoc "width" snap))))
      (setq *rp:cset* snap *rp:cpar* (list (cons "width" (cdr (assoc "width" snap)))))
      (setq pl0 (rp:lane-plan w))
      (setq res (rp:cdialog (strcat "Road " (rp:xv "NAME" data) " - changes apply to this road (and become the defaults for new roads).")))
      (setq *rp:cpar* nil)
      (if (= res 'ok)
        (progn
          ;; new snapshot = road settings with the corridor keys from the dialog
          (setq new (append (mapcar '(lambda (k) (cons k (rp:val k))) *rp:ckeys*)
                            (vl-remove-if '(lambda (p) (member (car p) *rp:ckeys*)) snap)))
          (setq *rp:cset* new pl1 (rp:lane-plan w) *rp:cset* nil)
          (if (and (equal (car pl0) (car pl1) 1e-6) (equal (cdr (reverse pl0)) (cdr (reverse pl1)) 1e-6)
                   (= (cdr (assoc "cmed" snap)) (cdr (assoc "cmed" new))))
            (progn
              ;; same road width and lanes : targeted update of the corridor only
              (vlax-ldata-put obj "ROADPRO_SET" new)
              (rp:corr-run e)
              (if (vlax-ldata-get obj "ROADPRO_MKMAN") (rp:mark-run e))
              (princ "\n  Corridor updated (sidewalks, walkways, drains, utilities, hatch). Run RDR / RDX to refresh the report and sections."))
            (progn
              (princ (strcat "\n  Lanes / median changed: road width " (rtos (car pl0) 2 2) " m -> " (rtos (car pl1) 2 2) " m."))
              (rp:rebuild e new))))
        (setq *rp:cset* nil))))
  (rp:finish))

;; Regenerate corridor + markings of a road (after edits made outside RoadPro)
(defun c:ROADUPDATE (/ sel e obj)
  (rp:start) (rp:space) (rp:world) (rp:linetypes) (rp:layers)
  (if (setq sel (rp:pick-road "\nSelect the road centre line (layer ROAD-CL): "))
    (progn
      (setq e (car sel) obj (vlax-ename->vla-object e))
      (setq *rp:cset* (vlax-ldata-get obj "ROADPRO_SET"))
      (if (and (vlax-ldata-get obj "ROADPRO_SET") (rp:corr-any))
        (progn (rp:corr-run e) (princ "\n  Corridor regenerated."))
        (princ "\n  This road has no corridor items (median / sidewalks / walkways / drains / utilities) - use RDC to add them."))
      (setq *rp:cset* nil)
      (if (vlax-ldata-get obj "ROADPRO_MKMAN") (progn (rp:mark-run e) (princ "\n  Road markings regenerated.")))))
  (rp:finish))

;; LandXML export of a road centre line (Civil 3D : Insert > LandXML)
(defun c:ROADLANDXML (/ sel e data path nm)
  (rp:start)
  (while (and (setq sel (entsel "\nSelect the road centre line or a polyline to export: "))
              (/= (cdr (assoc 0 (entget (car sel)))) "LWPOLYLINE"))
    (princ "\n  Select a 2D polyline (a RoadPro centre line is a polyline)."))
  (if sel
    (progn
      (setq e (car sel) data (rp:xget e)
            nm (if (and data (/= (rp:xv "NAME" data) "")) (rp:xv "NAME" data) "ALIGNMENT")
            path (strcat (getvar "DWGPREFIX") (vl-string-translate "\\/:*?\"<>| " "__________" nm) "_Alignment.xml"))
      (if (rp:lx-export e path)
        (princ (strcat "\n  LandXML 1.2 alignment saved : " path
                       "\n  In Civil 3D : Insert > LandXML (or LANDXMLIN), tick the alignment."))
        (princ (strcat "\n  Could not write " path " - is the file open?")))))
  (rp:finish))

;; LandXML import : every alignment of the file becomes a polyline (layer ROAD-LANDXML)
(defun c:ROADLANDXMLIN (/ path res)
  (rp:start) (rp:space) (rp:world) (rp:layers)
  (if (setq path (getfiled "Select a LandXML file" (getvar "DWGPREFIX") "xml" 0))
    (progn
      (setq res (rp:lx-import path))
      (foreach r res
        (princ (strcat "\n  Alignment " (cadr r) " imported, start station " (rtos (caddr r) 2 3)
                       " - build it with RDP (Centre line input: Select existing) and Start chainage " (rtos (caddr r) 2 3) ".")))
      (if (null res) (princ "\n  No alignment found in the file."))))
  (rp:finish))

(defun c:RDC   () (c:ROADCORRIDOR))
(defun c:RDU   () (c:ROADUPDATE))
(defun c:RDER  () (c:ROADEDITRADIUS))
(defun c:RDB   () (c:ROADREBUILD))
(defun c:RDLX  () (c:ROADLANDXML))
(defun c:RDLXI () (c:ROADLANDXMLIN))

;; Refresh markings + corridor of a road after RDW / RDT changed its edges
(defun rp:refresh (e / obj)
  (setq obj (vlax-ename->vla-object e))
  (if (vlax-ldata-get obj "ROADPRO_MKMAN") (rp:mark-run e))
  (rp:refresh-corr e)
  (rp:track e *rp:mk0*))

(defun rp:refresh-corr (e / obj)
  (setq obj (vlax-ename->vla-object e) *rp:cset* (vlax-ldata-get obj "ROADPRO_SET"))
  (if (and *rp:cset* (rp:corr-any)) (rp:corr-run e))
  (setq *rp:cset* nil))

;;----------------------------------------------------------------------------
;;  SINGLE LINE (RDL) : barricades, traffic cones or kerb stone along any
;;  line, polyline, arc or spline - on the line, offset left / right, or both
;;----------------------------------------------------------------------------
(setq *rp:ldefaults*
  '(("ltype" . "0") ("lside" . "0") ("loff" . "0.50") ("llen" . "2.00") ("lwid" . "0.50")
    ("lfrom" . "0") ("lto" . "0") ("llab" . "1")))
(setq *rp:lkeys*    (mapcar 'car *rp:ldefaults*)
      *rp:defaults* (append *rp:defaults* *rp:ldefaults*))

(setq *rp:ldcl*
 (list
  "roadline : dialog {"
  "  label = \"ROAD PRO  -  Single Line (barricades / cones / kerb stone)\";"
  "  : text { key = \"info\"; width = 60; }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"What to place\";"
  "      : popup_list { key = \"ltype\"; label = \"Type:\";      edit_width = 24; }"
  "      : popup_list { key = \"lside\"; label = \"Placement:\"; edit_width = 24; }"
  "      : edit_box   { key = \"loff\";  label = \"Offset from the line (m):\";        edit_width = 7; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Size and range\";"
  "      : edit_box { key = \"llen\";  label = \"Unit length / cone spacing (m):\"; edit_width = 7; }"
  "      : edit_box { key = \"lwid\";  label = \"Unit / cone / kerb width (m):\";   edit_width = 7; }"
  "      : edit_box { key = \"lfrom\"; label = \"From distance along line (m):\";  edit_width = 7; }"
  "      : edit_box { key = \"lto\";   label = \"To distance (m, 0 = line end):\"; edit_width = 7; }"
  "      : toggle   { key = \"llab\";  label = \"Quantity label on the drawing\"; }"
  "    }"
  "  }"
  "  : text { label = \"Left / right are seen looking along the line from its start point.\"; }"
  "  : text { label = \"Developed by https://www.exceltokml.com/\"; alignment = right; }"
  "  ok_cancel;"
  "  errtile;"
  "}"))

(defun rp:ldlg-modes ()
  (mode_tile "loff" (if (= (get_tile "lside") "0") 1 0)))

(defun rp:ldlg-accept (/ bad v)
  (foreach k '(("llen" "Unit length / spacing" 0) ("lwid" "Width" 0) ("loff" "Offset" 1)
               ("lfrom" "From distance" 1) ("lto" "To distance" 1))
    (if (not bad)
      (progn
        (setq v (rp:dist (get_tile (car k))))
        (if (or (null v) (if (= (caddr k) 1) (< v 0.0) (<= v 0.0))) (setq bad k)))))
  (cond
    (bad
     (set_tile "error" (strcat (cadr bad) (if (= (caddr bad) 1) " must be zero or a positive number."
                                             " must be a number greater than zero.")))
     (mode_tile (car bad) 2))
    ((and (> (rp:dist (get_tile "lto")) 0.0) (<= (rp:dist (get_tile "lto")) (rp:dist (get_tile "lfrom"))))
     (set_tile "error" "To distance must be greater than From distance, or 0 for the line end.")
     (mode_tile "lto" 2))
    (T (foreach k *rp:lkeys* (rp:set k (get_tile k))) (done_dialog 1))))

(defun rp:ldialog (info / fn f id res)
  (setq fn (vl-filename-mktemp "roadline.dcl"))
  (if (setq f (open fn "w"))
    (progn
      (foreach l *rp:ldcl* (write-line l f))
      (close f)
      (setq id (load_dialog fn))
      (if (and id (not (minusp id)) (new_dialog "roadline" id))
        (progn
          (rp:fill "ltype" '("Barricades (red / white)" "Traffic cones" "Kerb stone"))
          (rp:fill "lside" '("On the line (centred)" "Offset to the left" "Offset to the right" "Both sides"))
          (foreach k *rp:lkeys* (set_tile k (rp:val k)))
          (set_tile "info" info)
          (rp:ldlg-modes)
          (action_tile "lside" "(rp:ldlg-modes)")
          (action_tile "accept" "(rp:ldlg-accept)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq res (if (= (start_dialog) 1) 'ok 'cancel)))
        (setq res 'fail))
      (if (and id (not (minusp id))) (unload_dialog id))
      (vl-file-delete fn))
    (setq res 'fail))
  res)

;; Place the run on one curve, returns (red white cones kerb-m)
(defun rp:line-run (o fac elev / len a b w off sides tot r sub ip mt txt an)
  (setq len  (vlax-curve-getDistAtParam o (vlax-curve-getEndParam o))
        a    (* fac (rp:num "lfrom"))
        b    (if (> (rp:num "lto") 0.0) (min len (* fac (rp:num "lto"))) len)
        w    (* fac (rp:num "lwid"))
        off  (* fac (rp:num "loff"))
        tot  (list 0 0 0 0.0))
  (if (>= a b)
    (progn (princ "\n  Range is outside this line - skipped.") tot)
    (progn
      ;; work on a copy trimmed to the range, so units start at the From distance
      (setq sub (if (or (> a 1e-6) (< b (- len 1e-6))) (rp:subcurve o a b elev) o)
            len (vlax-curve-getDistAtParam sub (vlax-curve-getEndParam sub))
            *rp:len* len)
      (foreach sd (cond ((= (rp:val "lside") "1") '(1.0)) ((= (rp:val "lside") "2") '(-1.0))
                        ((= (rp:val "lside") "3") '(1.0 -1.0)) (T '(0.0)))
        (setq r (if (= sd 0.0)
                  (rp:edge-run sub len (* -0.5 w) (* 0.5 w) (rp:val "ltype") (* fac (rp:num "llen")) fac elev)
                  (rp:edge-run sub len (* sd off) (* sd (+ off w)) (rp:val "ltype") (* fac (rp:num "llen")) fac elev))
              tot (list (+ (car tot) (car r)) (+ (cadr tot) (cadr r)) (+ (caddr tot) (caddr r)) (+ (cadddr tot) (cadddr r)))))
      (if (rp:on "llab")
        (progn
          (setq txt (cond ((= (rp:val "ltype") "1") (strcat (itoa (caddr tot)) " TRAFFIC CONES"))
                          ((= (rp:val "ltype") "2") (strcat (rtos (/ (cadddr tot) fac) 2 1) " m KERB STONE"))
                          (T (strcat (itoa (+ (car tot) (cadr tot))) " BARRICADES (" (itoa (car tot)) " R / "
                                     (itoa (cadr tot)) " W)")))
                ip  (rp:offpt sub (* 0.5 len) (+ (if (= (rp:val "lside") "2") (- (+ off w)) (+ off w)) (* 1.5 fac)))
                mt  (rp:text txt ip (* 0.8 fac (rp:num "txth")) "ROAD-JUNCTION" elev))
          (setq an (angle '(0.0 0.0) (caddr (rp:frame sub (* 0.5 len)))))
          (vla-put-Rotation mt (if (and (> an (* 0.5 pi)) (<= an (* 1.5 pi))) (+ an pi) an))))
      (if (not (eq sub o)) (vla-Delete sub))
      tot)))

;; Copy of curve o between distances a and b (as a lightweight polyline)
(defun rp:subcurve (o a b elev / n i pts d)
  (setq n (max 2 (fix (+ 1.0 (/ (- b a) (* 0.25 *rp:lfac*)))))
        n (min n 4000) i 0)
  (repeat (1+ n)
    (setq d (+ a (* (- b a) (/ (float i) n)))
          pts (cons (list (rp:p2 (vlax-curve-getPointAtDist o (min d (vlax-curve-getDistAtParam o (vlax-curve-getEndParam o))))) 0.0) pts)
          i (1+ i)))
  (rp:mkpl (reverse pts) "ROAD-JUNCTION" elev nil))

(defun c:ROADLINE (/ ss res fac i o tot r elev)
  (rp:start)
  (rp:space)
  (rp:world)
  (rp:linetypes)
  (rp:layers)
  (setq fac (if (= (rp:val "units") "1") 1000.0 1.0)
        *rp:lfac* fac
        *rp:hatches* nil
        tot (list 0 0 0 0.0))
  (princ "\nSelect lines, polylines, arcs or splines for the single line run: ")
  (if (setq ss (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE,ARC,SPLINE,CIRCLE,ELLIPSE"))))
    (progn
      (setq res (rp:ldialog (strcat (itoa (sslength ss)) " object(s) selected   |   drawing units : "
                                    (if (= fac 1.0) "metres" "millimetres") " (set in RDP)")))
      (if (= res 'fail) (princ "\nDialog not available - using saved single line settings."))
      (if (/= res 'cancel)
        (progn
          (setq i 0)
          (repeat (sslength ss)
            (setq o    (vlax-ename->vla-object (ssname ss i))
                  elev (if (vlax-property-available-p o 'Elevation) (vla-get-Elevation o) 0.0)
                  r    (rp:line-run o fac elev)
                  tot  (list (+ (car tot) (car r)) (+ (cadr tot) (cadr r)) (+ (caddr tot) (caddr r)) (+ (cadddr tot) (cadddr r)))
                  i    (1+ i)))
          (if *rp:hatches* (rp:toback *rp:hatches*))
          (princ "\n================ ROAD PRO - SINGLE LINE ================")
          (if (> (+ (car tot) (cadr tot)) 0)
            (princ (strcat "\n  Barricade units : " (itoa (+ (car tot) (cadr tot))) "  (" (itoa (car tot)) " red / "
                           (itoa (cadr tot)) " white)")))
          (if (> (caddr tot) 0) (princ (strcat "\n  Traffic cones   : " (itoa (caddr tot)))))
          (if (> (cadddr tot) 0.0) (princ (strcat "\n  Kerb stone      : " (rtos (/ (cadddr tot) fac) 2 1) " m")))
          (princ "\n  Type U to undo this run in one step.")
          (princ "\n======================================================="))
        (princ "\nSingle line cancelled.")))
    (princ "\nNothing selected."))
  (rp:finish))

(defun c:RDL () (c:ROADLINE))

;;============================================================================
;;  v3.5  GEOMETRY HELPERS : 2D vectors, arcs, polygon clipping, offsets
;;============================================================================
(defun rp:v+ (a b) (list (+ (car a) (car b)) (+ (cadr a) (cadr b))))
(defun rp:v- (a b) (list (- (car a) (car b)) (- (cadr a) (cadr b))))
(defun rp:v* (a k) (list (* k (car a)) (* k (cadr a))))
(defun rp:dot (a b) (+ (* (car a) (car b)) (* (cadr a) (cadr b))))
(defun rp:crs (a b) (- (* (car a) (cadr b)) (* (cadr a) (car b))))
(defun rp:lnorm (u) (list (- (cadr u)) (car u)))
(defun rp:tan (a) (/ (sin a) (cos a)))
(defun rp:asin (x) (atan x (sqrt (max 0.0 (- 1.0 (* x x))))))
(defun rp:mod2pi (a)
  (while (< a 0.0) (setq a (+ a (* 2.0 pi))))
  (while (>= a (* 2.0 pi)) (setq a (- a (* 2.0 pi))))
  a)

;; Point and unit tangent of curve obj at distance s (clamped to the curve)
(defun rp:clpt (obj s / len par)
  (setq len (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
        s   (max 0.0 (min s len))
        par (vlax-curve-getParamAtDist obj s))
  (if (null par)
    (setq par (if (< s (* 0.5 len)) (vlax-curve-getStartParam obj) (vlax-curve-getEndParam obj))))
  (list (rp:p2 (vlax-curve-getPointAtParam obj par))
        (rp:unitv (vlax-curve-getFirstDeriv obj par))))

;; Station of the point of curve obj closest to p
(defun rp:sta (obj p / q)
  (setq q (vlax-curve-getDistAtPoint obj (rp:cpt obj p)))
  (if q q 0.0))

;; Point of any curve obj at station d, side offset off (+ = left)
(defun rp:opt (obj d off)
  (setq *rp:len* (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj)))
  (rp:offpt obj d off))

;; 2D point as a variant (LWPOLYLINE vertex)
(defun rp:pt2var (p)
  (vlax-make-variant
    (vlax-safearray-fill (vlax-make-safearray vlax-vbDouble '(0 . 1)) (list (car p) (cadr p)))))

;; Centre of the arc from p to q with bulge b
(defun rp:arc-centre (p q b / d)
  (setq d (distance p q))
  (rp:v+ (list (* 0.5 (+ (car p) (car q))) (* 0.5 (+ (cadr p) (cadr q))))
         (rp:v* (rp:lnorm (rp:unit2 p q)) (* 0.25 d (/ (- 1.0 (* b b)) b)))))

;; Bulge of the minor arc about centre c from p to q
(defun rp:minarc-bulge (c p q)
  (rp:tan (* 0.25 (rp:angdiff (angle c p) (angle c q)))))

;; Points along a polyline (vertex list pts + bulges bul); arcs sampled every step
(defun rp:pl-sample (pts bul closed step / out n i p q b th r c a0 m k)
  (setq n (length pts) i 0)
  (repeat (if closed n (max 0 (1- n)))
    (setq p   (nth i pts)
          q   (nth (rem (1+ i) n) pts)
          b   (nth i bul)
          out (cons p out))
    (if (and b (> (abs b) 1e-9) (> (distance p q) 1e-9))
      (progn
        (setq th (* 4.0 (atan b))
              r  (/ (distance p q) (* 2.0 (abs (sin (* 0.5 th)))))
              c  (rp:arc-centre p q b)
              a0 (angle c p)
              m  (max 2 (min 72 (fix (+ 0.999 (/ (* r (abs th)) step)))))
              k  1)
        (repeat (1- m)
          (setq out (cons (polar c (+ a0 (* th (/ (float k) m))) r) out) k (1+ k)))))
    (setq i (1+ i)))
  (if (and (not closed) pts) (setq out (cons (last pts) out)))
  (reverse out))

;; Area of a polygon (list of points)
(defun rp:parea (pts / a n i p q)
  (setq a 0.0 n (length pts) i 0)
  (repeat n
    (setq p (nth i pts)
          q (nth (rem (1+ i) n) pts)
          a (+ a (- (* (car p) (cadr q)) (* (car q) (cadr p))))
          i (1+ i)))
  (abs (* 0.5 a)))

;; Elements of list a that are also in list b
(defun rp:common (a b) (vl-remove-if-not '(lambda (x) (member x b)) a))

;; Intersection of edge s-e with a clip line; the new point carries the clip id
(defun rp:clip-ip (s e ds de id / k)
  (setq k (/ ds (- ds de)))
  (list (+ (car s) (* k (- (car e) (car s))))
        (+ (cadr s) (* k (- (cadr e) (cadr s))))
        (cons id (rp:common (caddr s) (caddr e)))))

;; Sutherland-Hodgman : part of polygon poly ((x y flags) ...) where (P - p0).nv >= 0
(defun rp:clip-half (poly p0 nv id / out n i s e ds de)
  (setq n (length poly) i 0)
  (if (> n 2)
    (repeat n
      (setq s  (nth i poly)
            e  (nth (rem (1+ i) n) poly)
            ds (rp:dot (rp:v- s p0) nv)
            de (rp:dot (rp:v- e p0) nv))
      (cond
        ((and (>= ds 0.0) (>= de 0.0)) (setq out (cons e out)))
        ((>= ds 0.0) (setq out (cons (rp:clip-ip s e ds de id) out)))
        ((>= de 0.0) (setq out (cons e (cons (rp:clip-ip s e ds de id) out)))))
      (setq i (1+ i))))
  (reverse out))

(defun rp:longest (objs / best bl l)
  (setq bl -1.0)
  (foreach o objs
    (setq l (vlax-curve-getDistAtParam o (vlax-curve-getEndParam o)))
    (if (> l bl) (setq best o bl l)))
  best)

;; Mean distance of a list of points from p
(defun rp:mdist (pts p / s)
  (setq s 0.0)
  (foreach q pts (setq s (+ s (distance (rp:p2 q) (rp:p2 p)))))
  (if pts (/ s (length pts)) 0.0))

;; Offset of a corner path kp ((x y bulge) ...) by r to the side AWAY from pref
;; (the land side). Returns (points bulges) or nil.
(defun rp:k-off (kp r pref elev / o res sel d0 d1 d2 pd)
  (setq o (rp:mkpl (mapcar '(lambda (v) (list (list (car v) (cadr v)) (caddr v))) kp) "0" elev nil))
  (if (< r 1e-6)
    (setq pd (rp:pldata o))
    (progn
      (setq d0 (rp:mdist (car (rp:pldata o)) pref))
      (foreach d (list r (- r))
        (if (setq res (rp:offset o d))
          (progn
            (setq sel (rp:longest res)
                  d1  (rp:mdist (car (rp:pldata sel)) pref))
            (if (and (> d1 d0) (or (null d2) (> d1 d2))) (setq d2 d1 pd (rp:pldata sel)))
            (foreach x res (vl-catch-all-apply 'vla-Delete (list x))))))))
  (vla-Delete o)
  pd)

;; Reverse a corner path ((x y bulge) ...)
(defun rp:kp-rev (kp / n i out)
  (setq n (length kp) i 0)
  (repeat n
    (setq out (cons (list (car (nth (- n 1 i) kp)) (cadr (nth (- n 1 i) kp))
                          (if (< i (1- n)) (- (caddr (nth (- n 2 i) kp))) 0.0))
                    out)
          i   (1+ i)))
  (reverse out))

(defun rp:ldata-add (obj key v) (vlax-ldata-put obj key (append (vlax-ldata-get obj key) (list v))))
(defun rp:ldata-addl (obj key lst) (vlax-ldata-put obj key (append (vlax-ldata-get obj key) lst)))

;; Add value v to the list stored under key k of alist al
(defun rp:aadd (al k v / a)
  (if (setq a (assoc k al))
    (subst (cons k (append (cdr a) (list v))) a al)
    (append al (list (cons k (list v))))))

;;============================================================================
;;  v3.5  CORRIDOR ROUND JUNCTION / ROUNDABOUT CORNERS
;;  Each corner is stored on BOTH roads (ldata ROADPRO_JCORN) as
;;   (id sg sT dirJ kpath pref draw wrap role other-handle other-sg other-sT other-dirJ)
;;   sg     side of this road where the corner lies     sT  station of the tangent point
;;   dirJ   +1 / -1 : direction of the junction along this road's chainage
;;   kpath  kerb line : far point on this road edge > kerb return / fillet
;;          (+ roundabout circle) > far point on the other road edge, ((x y bulge) ...)
;;   pref   a point on the road side     draw 1 = this road draws the corner pieces
;;   wrap   "ALL" every item wraps (roundabout) / "SWD" sidewalk, walkway, drain
;;   role   "A" through road / "B" branch (utility corridor and pipes T-join)
;;  Every corridor strip is offset from the kerb line (AutoCAD offset - fillets
;;  that close up become sharp corners), the straight strips are cut where the
;;  offset turns, and the corner piece between the two cuts is hatched.
;;============================================================================
;;============================================================================
;;  v3.6  CLEAN TIE-INS : helpers
;;============================================================================
;; Head of polyline obj from its start to station s0 : (points bulges), exact arcs
(defun rp:pl-head (obj s0 / pd pts bul i n out ob d0 d1 b)
  (setq pd (rp:pldata obj) pts (car pd) bul (cadr pd) i 0
        n  (fix (+ 0.5 (vlax-curve-getEndParam obj))))
  (while (and (< i n) (< (vlax-curve-getDistAtParam obj i) (- s0 1e-9)))
    (setq d0  (vlax-curve-getDistAtParam obj i)
          d1  (vlax-curve-getDistAtParam obj (1+ i))
          b   (nth i bul)
          out (cons (rp:p2 (nth i pts)) out)
          ob  (cons (if (> d1 s0) (rp:tan (* (/ (- s0 d0) (- d1 d0)) (atan b))) b) ob)
          i   (1+ i)))
  (setq out (cons (rp:p2 (vlax-curve-getPointAtDist obj s0)) out) ob (cons 0.0 ob))
  (list (reverse out) (reverse ob)))

;; Put a stored head ((pts) (bulges)) back in front of polyline obj
(defun rp:pl-prepend (obj hd / pd)
  (setq pd (rp:pldata obj))
  (rp:pl-set obj (append (reverse (cdr (reverse (car hd)))) (car pd))
                 (append (reverse (cdr (reverse (cadr hd)))) (cadr pd))))

;; Points along curve e from station a to station b (either direction)
(defun rp:edge-pts (e a b fac / n i out l)
  (setq l (vlax-curve-getDistAtParam e (vlax-curve-getEndParam e))
        a (max 0.0 (min a l)) b (max 0.0 (min b l))
        n (max 1 (fix (+ 0.999999 (/ (abs (- b a)) (* 0.5 fac))))) i 0)
  (repeat (1+ n)
    (setq out (cons (rp:p2 (vlax-curve-getPointAtDist e (+ a (* (- b a) (/ (float i) n))))) out) i (1+ i)))
  (reverse out))

;; Drop repeated points (and a closing point equal to the first)
(defun rp:dedupe (pts tol / out)
  (foreach p pts (if (or (null out) (> (distance p (car out)) tol)) (setq out (cons p out))))
  (if (and (cdr out) (< (distance (car out) (last out)) tol)) (setq out (cdr out)))
  (reverse out))

;; Paved shoulder band along a widening profile (side sg, stations a..b)
(defun rp:band-prof (cl a b sg hw gap prof lay elev fac / s0 s1 n i d o pa pb bnd h)
  (setq s0 a)
  (while (< s0 (- b 1e-6))
    (setq s1 (min b (+ s0 (* 50.0 fac)))
          n  (max 1 (fix (+ 0.999999 (/ (- s1 s0) (* 0.5 fac)))))
          i  0 pa nil pb nil)
    (repeat (1+ n)
      (setq d  (+ s0 (* (- s1 s0) (/ (float i) n)))
            o  (rp:prof-o prof d)
            pa (cons (rp:offpt cl d (* sg (+ hw o))) pa)
            pb (cons (rp:offpt cl d (* sg (+ hw o gap))) pb)
            i  (1+ i)))
    (setq bnd (rp:poly (append (reverse pa) pb) lay elev)
          h   (rp:newhatch "SOLID" nil elev))
    (vla-put-Layer h lay)
    (if (not (vl-catch-all-error-p (vl-catch-all-apply 'vla-AppendOuterLoop (list h (rp:objarr (list bnd))))))
      (progn
        (vla-Evaluate h)
        (setq *rp:hatches* (cons h *rp:hatches*))
        (rp:ldata-add cl "ROADPRO_SHLD" (list (vla-get-Handle h) s0 s1 (* sg hw) (* sg (+ hw gap)) prof)))
      (vla-Delete h))
    (vla-Delete bnd)
    (setq s0 s1)))

;; Remove the paved shoulder of road obj on side sg between stations a and b
;; (the pieces outside a..b are drawn again). Returns the number of pieces cut.
(defun rp:shld-cut (obj sg a b fac elev / keep cut x en hw gap)
  (if (> a b) (setq x a a b b x))
  (foreach r (vlax-ldata-get obj "ROADPRO_SHLD")
    (if (and (> (* sg (+ (nth 3 r) (nth 4 r))) 0.0) (> (nth 2 r) (+ a 1e-6)) (< (nth 1 r) (- b 1e-6)))
      (setq cut (cons r cut))
      (setq keep (cons r keep))))
  (vlax-ldata-put obj "ROADPRO_SHLD" (reverse keep))
  (setq *rp:len* (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj)))
  (foreach r cut
    (if (and (setq en (handent (car r))) (entget en)) (entdel en))
    (setq hw (abs (nth 3 r)) gap (- (abs (nth 4 r)) (abs (nth 3 r))))
    (foreach rg (list (list (nth 1 r) (min a (nth 2 r))) (list (max b (nth 1 r)) (nth 2 r)))
      (if (> (- (cadr rg) (car rg)) (* 0.01 fac))
        (if (nth 5 r)
          (rp:band-prof obj (car rg) (cadr rg) sg hw gap (nth 5 r) "ROAD-SHOULDER" elev fac)
          (rp:band obj (car rg) (cadr rg) (nth 3 r) (nth 4 r) "ROAD-SHOULDER" elev fac nil)))))
  (length cut))

;; Cut station on road obj : vertex 1 (this road) or n-2 (other road) of each
;; offset path, together with the tangent station sT
(defun rp:jc-cutsta (obj kps this sT dirJ / ss pts)
  (setq ss (list sT))
  (foreach kd kps
    (setq pts (car kd))
    (if (>= (length pts) 3)
      (setq ss (cons (rp:sta obj (if this (cadr pts) (nth (- (length pts) 2) pts))) ss))))
  (if (> dirJ 0) (apply 'min ss) (apply 'max ss)))

;; Branch utility corridor / pipe : station where it meets the outer line of the
;; same item on the through road (T-joint). Returns the cut station or nil
(defun rp:jc-tjoin (rec o1 o2 obj elev / kp pref kb ka p q c d ip ss)
  (setq kp (nth 4 rec) pref (nth 5 rec)
        kb (rp:k-off kp o2 pref elev))
  (if kb
    (progn
      (setq p (car kb)
            c (nth (- (length p) 2) p)
            d (last p))
      (foreach r (list o1 o2)
        (if (setq ka (if (equal r o2 1e-9) kb (rp:k-off kp r pref elev)))
          (progn
            (setq q (car ka))
            (if (setq ip (inters (car q) (cadr q) c d nil))
              (setq ss (cons (rp:sta obj ip) ss))))))
      (if ss (if (> (nth 3 rec) 0) (apply 'min ss) (apply 'max ss))))))

(defun rp:flag (pts / n i out)
  (setq n (length pts) i 0)
  (foreach p pts
    (setq out (cons (list (car p) (cadr p) (if (or (= i 0) (= i (1- n))) '(9) nil)) out)
          i   (1+ i)))
  (reverse out))

(defun rp:jc-run (run lay elev)
  (if (cdr run) (rp:mkpl (mapcar '(lambda (p) (list p 0.0)) run) lay elev nil)))

;; Draw the corner piece of one corridor strip. kk = (inner outer) offset paths,
;; cut = this road's cut station. Returns the area (drawing units).
(defun rp:jc-draw (rec kk cut obj lay kind lines elev fac / oth oobj cutb s1 s2 poly f g ar tot bnd h run a b i n
                                                             nc k i1 i2 j1 j2 hang)
  (setq oth (handent (nth 9 rec)) tot 0.0)
  (if (and oth (entget oth))
    (progn
      (setq oobj (vlax-ename->vla-object oth)
            cutb (rp:jc-cutsta oobj kk nil (nth 11 rec) (nth 12 rec))
            s1   (rp:pl-sample (car (car kk)) (cadr (car kk)) nil (* 0.5 fac))
            s2   (rp:pl-sample (car (cadr kk)) (cadr (cadr kk)) nil (* 0.5 fac))
            f    (rp:clpt obj cut)
            g    (rp:clpt oobj cutb)
            ;; v3.6 : the paving pattern runs the same way as on the through road
            hang (angle '(0.0 0.0) (cadr (if (= (nth 8 rec) "B") g f)))
            ;; v3.6 : long corner pieces are hatched in pieces of about 25 m (a very
            ;; large paver hatch is too dense for AutoCAD and shows as a flat fill)
            nc   (max 1 (fix (+ 0.999999 (/ (rp:plen s1) (* 25.0 fac)))))
            k    0)
      (repeat nc
        (setq i1 (fix (+ 0.5 (* (/ (float k) nc) (1- (length s1)))))
              i2 (fix (+ 0.5 (* (/ (float (1+ k)) nc) (1- (length s1)))))
              j1 (fix (+ 0.5 (* (/ (float k) nc) (1- (length s2)))))
              j2 (fix (+ 0.5 (* (/ (float (1+ k)) nc) (1- (length s2)))))
              poly (append (rp:flag (rp:sublist s1 i1 i2)) (reverse (rp:flag (rp:sublist s2 j1 j2))))
              poly (rp:clip-half poly (car f) (rp:v* (cadr f) (nth 3 rec)) 1)
              poly (rp:clip-half poly (car g) (rp:v* (cadr g) (nth 12 rec)) 2)
              ar   (if (> (length poly) 2) (rp:parea poly) 0.0)
              k    (1+ k))
        (if (> ar (* 0.01 fac fac))
          (progn
            (setq tot (+ tot ar))
            (if kind
              (progn
                (setq bnd (rp:poly (mapcar 'rp:p2 poly) lay elev)
                      h   (rp:chatch kind elev fac hang))
                (vla-put-Layer h lay)
                (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-AppendOuterLoop (list h (rp:objarr (list bnd)))))
                  (vla-Delete h)
                  (progn (vl-catch-all-apply 'vla-Evaluate (list h)) (setq *rp:hatches* (cons h *rp:hatches*))))
                (vla-Delete bnd)))
            (if lines
              (progn
                ;; boundary lines along the kerb offsets only (not along the cuts / piece joints)
                (setq n (length poly) i 0 run nil)
                (repeat n
                  (setq a (nth i poly) b (nth (rem (1+ i) n) poly))
                  (if (rp:common (caddr a) (caddr b))
                    (progn (rp:jc-run run lay elev) (setq run nil))
                    (setq run (if run (append run (list (rp:p2 b))) (list (rp:p2 a) (rp:p2 b)))))
                  (setq i (1+ i)))
                (rp:jc-run run lay elev))))))
      tot)
    0.0))

(defun rp:plen (pts / l p)
  (setq l 0.0 p (car pts))
  (foreach q (cdr pts) (setq l (+ l (distance (rp:p2 p) (rp:p2 q))) p q))
  l)

(defun rp:sublist (lst i j / out k)
  (setq k 0)
  (foreach x lst (if (and (>= k i) (<= k j)) (setq out (cons x out))) (setq k (1+ k)))
  (reverse out))

;; Corner records of a priority junction (kerb returns), stored on both roads
(defun rp:jc-junction (mobj bobj res sg dJ id mdraw fac elev / pref lext ip t1 t2 tm ub dl b kp sTm dm sTb sb)
  (setq pref (car (rp:clpt mobj dJ)) lext (* 80.0 fac))
  (foreach cr res
    (setq ip (rp:p2 (caddr cr)) t1 (rp:p2 (car (nth 3 cr))) t2 (rp:p2 (last (nth 3 cr))))
    (if (and (> (distance t1 ip) (* 0.001 fac)) (> (distance t2 ip) (* 0.001 fac)))
      (progn
        (setq tm  (rp:unit2 ip t1)
              ub  (rp:unit2 ip t2)
              dl  (rp:acos (rp:dot (rp:v* tm -1.0) ub))
              b   (* (if (> (rp:crs (rp:v* tm -1.0) ub) 0.0) 1.0 -1.0) (rp:tan (* 0.25 dl)))
              kp  (list (append (rp:v+ t1 (rp:v* tm lext)) '(0.0)) (append t1 (list b))
                        (append t2 '(0.0)) (append (rp:v+ t2 (rp:v* ub lext)) '(0.0)))
              sTm (rp:sta mobj t1)
              dm  (if (< sTm dJ) 1.0 -1.0)
              sTb (rp:sta bobj t2)
              sb  (if (> (rp:lat bobj (cadr cr)) 0.0) 1.0 -1.0))
        (rp:ldata-add mobj "ROADPRO_JCORN"
                      (list id sg sTm dm kp pref (if mdraw 1 0) "SWD" "A" (vla-get-Handle bobj) sb sTb -1.0))
        (rp:ldata-add bobj "ROADPRO_JCORN"
                      (list id sb sTb -1.0 (rp:kp-rev kp) pref (if mdraw 0 1) "SWD" "B" (vla-get-Handle mobj) sg sTm dm))))))

;;----------------------------------------------------------------------------
;;  v3.5 : junction type (priority / roundabout) and design standard.
;;  Saudi Arabia : SHC 301 (Saudi Highway Code) / MOMRA practice, which follow
;;  AASHTO geometric design - TYPICAL values by road class / design vehicle and
;;  the main road speed. Always check them against the project standard.
;;----------------------------------------------------------------------------
(setq *rp:sa-cls* '("Local street - P (car)" "Collector - SU (single-unit truck)"
                    "Arterial - WB-15 (semi-trailer)" "Industrial / heavy - WB-19"))

;; (corner R, aux lane width, approach taper, departure taper, storage,
;;  island width, island length, time gap tg (s), design vehicle)
(defun rp:sa-vals (cls spd / w ratio lng dec)
  (setq cls   (max 0 (min 3 cls))
        w     (nth cls '(3.00 3.50 3.65 3.65))
        ratio (cond ((<= spd 50) 8.0) ((<= spd 60) 10.0) ((<= spd 70) 12.0) (T 15.0))
        lng   (max 30.0 (* 5.0 (fix (+ 0.999 (/ (* w ratio) 5.0)))))
        dec   (cond ((<= spd 40) 45.0) ((<= spd 50) 70.0) ((<= spd 60) 95.0) ((<= spd 70) 120.0)
                    ((<= spd 80) 140.0) ((<= spd 90) 165.0) ((<= spd 100) 190.0) (T 220.0)))
  (list (nth cls '(9.0 12.0 15.0 18.0)) w lng
        (max 15.0 (* 5.0 (fix (+ 0.999 (/ (* w 8.0) 5.0)))))
        (max 30.0 (- dec lng))
        (nth cls '(1.8 1.8 2.4 2.4))
        (if (<= spd 60) 15.0 30.0)
        (nth cls '(7.5 9.5 11.5 11.5))
        (nth cls '("P" "SU" "WB-15" "WB-19"))))

;; Dialog : fill the junction values from the Saudi standard (doit = T)
(defun rp:jstd-apply (doit / v sp)
  (setq sp (if *rp:jspd* *rp:jspd* 50.0)
        v  (rp:sa-vals (atoi (get_tile "jcls")) sp))
  (if (= (get_tile "jstd") "1")
    (progn
      (if doit
        (progn
          (set_tile "jrad"   (rtos (nth 0 v) 2 1))
          (set_tile "jauxw"  (rtos (nth 1 v) 2 2))
          (set_tile "jlong"  (rtos (nth 2 v) 2 0))
          (set_tile "jshort" (rtos (nth 3 v) 2 0))
          (set_tile "jstore" (rtos (nth 4 v) 2 0))
          (set_tile "jislw"  (rtos (nth 5 v) 2 1))
          (set_tile "jisll"  (rtos (nth 6 v) 2 0))
          (set_tile "jsight" "1")))
      (set_tile "jinfo" (strcat "Saudi Arabia SHC 301 / MOMRA (AASHTO based) : design vehicle " (nth 8 v)
                                ", main road " (rtos sp 2 0) " km/h, taper 1:"
                                (rtos (cond ((<= sp 50) 8.0) ((<= sp 60) 10.0) ((<= sp 70) 12.0) (T 15.0)) 2 0)
                                ".  Typical values - verify for the project.")))
    (set_tile "jinfo" "Manual : type the junction values (or choose Saudi Arabia to fill them from the standard).")))

;; Sight triangles at a priority junction (AASHTO / SHC case B1) : decision point
;; 4.4 m back from the main road edge in the branch approach lane, sight lines to
;; the near lane and the far lane at ISD = 0.278 V tg. Returns ISD (m)
(defun rp:sight (mobj bobj sg dJ hwm hwb fac elev spd tg / isd mlen blen d p1 p2 q1 q2 ip tx)
  (setq isd  (* 0.278 spd tg)
        mlen (vlax-curve-getDistAtParam mobj (vlax-curve-getEndParam mobj))
        blen (vlax-curve-getDistAtParam bobj (vlax-curve-getEndParam bobj))
        d    (rp:opt bobj (min blen (* 4.4 fac)) (* 0.5 hwb))
        q1   (rp:opt mobj dJ (* sg 0.5 hwm))
        p1   (rp:opt mobj (max 0.0 (min mlen (+ dJ (* sg isd fac)))) (* sg 0.5 hwm))
        q2   (rp:opt mobj dJ (* sg -0.5 hwm))
        p2   (rp:opt mobj (max 0.0 (min mlen (- dJ (* sg isd fac)))) (* sg -0.5 hwm)))
  (foreach tri (list (list d p1 q1) (list d p2 q2))
    (vl-catch-all-apply 'vla-put-LinetypeScale (list (rp:poly tri "ROAD-SIGHT" elev) (/ fac (getvar "LTSCALE")))))
  (setq ip (rp:opt bobj (min blen (* 12.0 fac)) (- (+ hwb (* 4.0 fac))))
        tx (vla-AddMText *rp:spc* (rp:p3 ip elev) (* 40.0 fac (rp:num "txth"))
             (strcat "SIGHT TRIANGLES (AASHTO / SHC CASE B1)\\PISD = " (rtos isd 2 0) " m  (V "
                     (rtos spd 2 0) " km/h, tg " (rtos tg 2 1) " s)\\PDECISION POINT 4.4 m FROM THE EDGE"
                     "\\PKEEP CLEAR OF OBSTRUCTIONS ABOVE 0.6 m")))
  (vla-put-Height tx (* 0.6 fac (rp:num "txth")))
  (vla-put-AttachmentPoint tx acAttachmentPointMiddleLeft)
  (vla-put-InsertionPoint tx (rp:p3 ip elev))
  (vla-put-Layer tx "ROAD-SIGHT")
  isd)

;; RDJ dialog : roundabout standard picked -> radius of that standard
(defun rp:jrb-std (/ i)
  (setq i (atoi (get_tile "rbstd")))
  (if (> i 0) (set_tile "rbr" (rtos (* 0.5 (nth 5 (rp:rb-row i))) 2 2))))

;; RDJ dialog : "More roundabout settings..." (nested dialog)
(defun rp:jrb-more ()
  (if (/= (get_tile "rbstd") (rp:val "rbstd")) (rp:rb-env (atoi (get_tile "rbstd"))))
  (rp:set "rbstd" (get_tile "rbstd"))
  (if (rp:dist (get_tile "rbr")) (rp:set "rbr" (get_tile "rbr")))
  (rp:rbdialog "Roundabout at the junction : the branch is the side road (legs are set in RDJ)." nil)
  (set_tile "rbstd" (rp:val "rbstd"))
  (set_tile "rbr" (rp:val "rbr")))

;;============================================================================
;;  v3.5  ROUNDABOUTS  -  US Federal Highway Administration (FHWA)
;;  "Roundabouts: An Informational Guide" 2000 (FHWA-RD-00-067) and
;;  2010 (second edition, NCHRP Report 672).
;;  Built on a RoadPro road (the through road) with any number of side roads
;;  (legs) that start at the roundabout centre. Traffic keeps right :
;;  anticlockwise circulation, entry on the right of each approach.
;;  Draws : outer kerb line with entry / exit fillets, circulatory roadway,
;;  truck apron, central island (raised or mountable), splitter islands with
;;  pedestrian crossings, yield lines + give-way triangles, circulating lane
;;  line (concentric or spiral), GIVE WAY / ROUNDABOUT AHEAD / KEEP RIGHT
;;  signs, chevrons, labels, ICD dimension, fillet radii, setting-out, report.
;;  Sidewalks / walkways / drains / utilities wrap round every corner.
;;============================================================================
;; name speed lanes ICDmin ICDmax ICD Wc apron Rentry Rexit splitterL splitterW
;; spiral mountable painted pedestrian note        (metres, km/h)
(setq *rp:rbstds*
 '(("Manual - user values"                                       0 1  0  0  0  0.0 0.0  0  0  0 0.0 0 0 0 0 "")
   ("FHWA 2000: Mini Roundabout"                                25 1 13 25 22  5.0 0.0 10 15  8 1.5 0 1 1 1 "fully traversable central island")
   ("FHWA 2000: Rural Double Lane Roundabout"                   50 2 55 60 58 10.0 3.0 35 50 40 4.5 0 0 0 0 "extended splitter islands")
   ("FHWA 2000: Rural Double Lane Spiral Marking Roundabout"    50 2 55 60 58 10.0 3.0 35 50 40 4.5 1 0 0 0 "spiral lane markings")
   ("FHWA 2000: Rural Single Lane Roundabout"                   40 1 35 40 38  5.5 3.0 25 40 30 3.5 0 0 0 0 "extended splitter islands")
   ("FHWA 2000: Urban Compact Roundabout"                       25 1 25 30 28  5.0 2.0 12 15 12 2.5 0 0 0 1 "perpendicular entries and exits")
   ("FHWA 2000: Urban Double Lane Roundabout"                   40 2 45 55 50  9.5 2.0 30 40 20 4.0 0 0 0 1 "")
   ("FHWA 2000: Urban Double Lane Spiral Marking Roundabout"    40 2 45 55 50  9.5 2.0 30 40 20 4.0 1 0 0 1 "spiral lane markings")
   ("FHWA 2000: Urban Single Lane Roundabout"                   35 1 30 40 35  5.5 2.5 20 30 15 3.0 0 0 0 1 "")
   ("Guide 2010 (NCHRP 672): Mini-Roundabout"                   30 1 14 27 22  5.0 0.0 10 15  8 1.5 0 1 1 1 "fully traversable central island")
   ("Guide 2010 (NCHRP 672): Single-Lane Roundabout"            40 1 27 55 40  5.5 3.0 20 30 20 3.5 0 0 0 1 "")
   ("Guide 2010 (NCHRP 672): Multilane Roundabout"              45 2 46 91 55  9.5 3.0 30 45 25 4.5 0 0 0 1 "")
   ("Guide 2010 (NCHRP 672): Multilane Spiral Marking"          45 2 46 91 55  9.5 3.0 30 45 25 4.5 1 0 0 1 "spiral lane markings")))

(setq *rp:rbdefaults*
  '(("rbstd" . "7")    ("rbr" . "25.00")  ("rbcw" . "9.50")  ("rbap" . "2.00")  ("rbent" . "30.00")
    ("rbext" . "40.00") ("rblane" . "1")  ("rbspl" . "20.00") ("rbspw" . "4.00") ("rbspt" . "0")
    ("rbped" . "1")    ("rbmark" . "1")   ("rbspir" . "1")   ("rbsign" . "1")   ("rbtrav" . "0")
    ("rbspd" . "40")   ("rbleg" . "3")    ("rblegm" . "0")   ("rbbn" . "RB-LEG") ("rbbw" . "7.30")
    ("rbll" . "60")))
(setq *rp:rbkeys*   (mapcar 'car *rp:rbdefaults*)
      *rp:defaults* (append *rp:defaults* *rp:rbdefaults*))

(defun rp:rb-row (i) (nth (max 0 (min (1- (length *rp:rbstds*)) i)) *rp:rbstds*))

(defun rp:rb-info (i / r)
  (setq r (rp:rb-row i))
  (if (<= i 0)
    "Manual : type your own values."
    (strcat "Design speed " (rtos (nth 1 r) 2 0) " km/h  |  " (rtos (nth 2 r) 2 0) " circulating lane(s)  |  ICD "
            (rtos (nth 3 r) 2 0) " - " (rtos (nth 4 r) 2 0) " m"
            (if (/= (nth 16 r) "") (strcat "  |  " (nth 16 r)) ""))))

;; values of standard i : list of (key . text)
(defun rp:rb-vals (i / r)
  (setq r (rp:rb-row i))
  (list (cons "rbr"    (rtos (* 0.5 (nth 5 r)) 2 2)) (cons "rbcw"  (rtos (nth 6 r) 2 2))
        (cons "rbap"   (rtos (nth 7 r) 2 2))         (cons "rbent" (rtos (nth 8 r) 2 2))
        (cons "rbext"  (rtos (nth 9 r) 2 2))         (cons "rbspl" (rtos (nth 10 r) 2 2))
        (cons "rbspw"  (rtos (nth 11 r) 2 2))        (cons "rbspd" (rtos (nth 1 r) 2 0))
        (cons "rblane" (itoa (max 0 (1- (fix (nth 2 r))))))
        (cons "rbspir" (if (= (nth 12 r) 1) "1" "0")) (cons "rbtrav" (if (= (nth 13 r) 1) "1" "0"))
        (cons "rbspt"  (if (= (nth 14 r) 1) "1" "0")) (cons "rbped"  (if (= (nth 15 r) 1) "1" "0"))))

(defun rp:rb-env (i) (if (> i 0) (foreach p (rp:rb-vals i) (rp:set (car p) (cdr p)))))
(defun rp:rb-apply (i)
  (if (> i 0) (foreach p (rp:rb-vals i) (set_tile (car p) (cdr p))))
  (set_tile "rbinfo" (rp:rb-info i)))

(setq *rp:rbdcl*
 (list
  "roadrbt : dialog {"
  "  label = \"ROAD PRO  -  Roundabout (FHWA  Roundabouts: An Informational Guide 2000 / 2010)\";"
  "  : text { key = \"info\"; width = 100; }"
  "  : boxed_column {"
  "    label = \"Design standard  -  US Federal Highway Administration\";"
  "    : popup_list { key = \"rbstd\"; edit_width = 62; }"
  "    : text { key = \"rbinfo\"; width = 100; }"
  "  }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Geometry\";"
  "      : edit_box   { key = \"rbr\";    label = \"Inscribed radius R = ICD / 2 (m):\"; edit_width = 7; }"
  "      : edit_box   { key = \"rbcw\";   label = \"Circulatory roadway width (m):\";   edit_width = 7; }"
  "      : edit_box   { key = \"rbap\";   label = \"Truck apron width (m, 0 = none):\"; edit_width = 7; }"
  "      : edit_box   { key = \"rbent\";  label = \"Entry radius (m):\";                edit_width = 7; }"
  "      : edit_box   { key = \"rbext\";  label = \"Exit radius (m):\";                 edit_width = 7; }"
  "      : popup_list { key = \"rblane\"; label = \"Circulating lanes:\";               edit_width = 18; }"
  "      : edit_box   { key = \"rbspd\";  label = \"Design speed (km/h):\";             edit_width = 7; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Islands, markings and signs\";"
  "      : edit_box   { key = \"rbspl\"; label = \"Splitter island length (m):\";       edit_width = 7; }"
  "      : edit_box   { key = \"rbspw\"; label = \"Splitter width at the circle (m):\"; edit_width = 7; }"
  "      : popup_list { key = \"rbspt\"; label = \"Splitter islands:\";                 edit_width = 16; }"
  "      : toggle { key = \"rbped\";  label = \"Pedestrian crossings on the legs\"; }"
  "      : toggle { key = \"rbmark\"; label = \"Yield lines, give-way triangles, lane lines\"; }"
  "      : toggle { key = \"rbspir\"; label = \"Spiral lane markings (2 lanes)\"; }"
  "      : toggle { key = \"rbsign\"; label = \"Give way, roundabout ahead, keep right, chevrons\"; }"
  "      : toggle { key = \"rbtrav\"; label = \"Mountable (traversable) central island\"; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Side roads (ROADROUNDABOUT)\";"
  "      : popup_list { key = \"rbleg\";  label = \"Layout:\";           edit_width = 36; }"
  "      : popup_list { key = \"rblegm\"; label = \"Side road centre line:\"; edit_width = 36; }"
  "      : edit_box   { key = \"rbll\";   label = \"Automatic leg length (m):\"; edit_width = 7; }"
  "      : edit_box   { key = \"rbbn\";   label = \"Road name:\";         edit_width = 10; }"
  "      : edit_box   { key = \"rbbw\";   label = \"Road width (m):\";    edit_width = 7; }"
  "      : text { label = \"Side roads start at the roundabout centre :\"; }"
  "      : text { label = \"drawn, selected, or made at 90 degrees.\"; }"
  "    }"
  "  }"
  "  : text { label = \"Values follow the selected guide. Check them against the project standard (QTCM / SHC / local authority).\"; }"
  "  : text { label = \"Developed by https://www.exceltokml.com/\"; alignment = right; }"
  "  ok_cancel;"
  "  errtile;"
  "}"))

(defun rp:rbdlg-modes ()
  (mode_tile "rbspir" (if (= (get_tile "rblane") "1") 0 1))
  (foreach k '("rbleg" "rblegm" "rbbn" "rbbw") (mode_tile k (if *rp:rblegs* 0 1)))
  (mode_tile "rbll" (if (and *rp:rblegs* (= (get_tile "rblegm") "2")) 0 1)))

(defun rp:rbdlg-std () (rp:rb-apply (atoi (get_tile "rbstd"))) (rp:rbdlg-modes))

(defun rp:rbdlg-accept (/ bad v)
  (foreach k '(("rbr" "Inscribed radius" 0) ("rbcw" "Circulatory width" 0) ("rbap" "Apron width" 1)
               ("rbent" "Entry radius" 0) ("rbext" "Exit radius" 0) ("rbspl" "Splitter island length" 0)
               ("rbspw" "Splitter island width" 0) ("rbspd" "Design speed" 0) ("rbbw" "Side road width" 0))
    (if (not bad)
      (progn
        (setq v (rp:dist (get_tile (car k))))
        (if (or (null v) (if (= (caddr k) 1) (< v 0.0) (<= v 0.0))) (setq bad k)))))
  (cond
    (bad
     (set_tile "error" (strcat (cadr bad) (if (= (caddr bad) 1) " must be zero or a positive number."
                                             " must be a number greater than zero.")))
     (mode_tile (car bad) 2))
    ((>= (rp:dist (get_tile "rbcw")) (rp:dist (get_tile "rbr")))
     (set_tile "error" "The circulatory width must be smaller than the inscribed radius.")
     (mode_tile "rbcw" 2))
    ((and (/= (get_tile "rbtrav") "1")
          (< (- (rp:dist (get_tile "rbr")) (rp:dist (get_tile "rbcw")) (rp:dist (get_tile "rbap"))) 0.5))
     (set_tile "error" "Central island radius (R - circulatory - apron) is below 0.5 m : reduce the widths or tick a mountable island.")
     (mode_tile "rbr" 2))
    (T
     (foreach k *rp:rbkeys* (rp:set k (get_tile k)))
     (done_dialog 1))))

;; legs = T : the side-road box is active (ROADROUNDABOUT). Returns 'ok / 'cancel / 'fail
(defun rp:rbdialog (info legs / fn f id res)
  (setq *rp:rblegs* legs
        fn (vl-filename-mktemp "roadrbt.dcl"))
  (if (setq f (open fn "w"))
    (progn
      (foreach l *rp:rbdcl* (write-line l f))
      (close f)
      (setq id (load_dialog fn))
      (if (and id (not (minusp id)) (new_dialog "roadrbt" id))
        (progn
          (set_tile "info" info)
          (rp:fill "rbstd"  (mapcar 'car *rp:rbstds*))
          (rp:fill "rblane" '("1 lane (single-lane)" "2 lanes (double-lane)"))
          (rp:fill "rbspt"  '("Raised - kerbed" "Painted / flush"))
          (rp:fill "rbleg"  '("2-way : no side road" "3-way (T) : side road on the left" "3-way (T) : side road on the right"
                              "4-way (cross) : side roads both sides"))
          (rp:fill "rblegm" '("Draw new (from the centre)" "Select existing" "Automatic : straight, at 90 degrees"))
          (foreach k *rp:rbkeys* (set_tile k (rp:val k)))
          (set_tile "rbinfo" (rp:rb-info (atoi (rp:val "rbstd"))))
          (rp:rbdlg-modes)
          (action_tile "rbstd"  "(rp:rbdlg-std)")
          (action_tile "rblane" "(rp:rbdlg-modes)")
          (action_tile "accept" "(rp:rbdlg-accept)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq res (if (= (start_dialog) 1) 'ok 'cancel)))
        (setq res 'fail))
      (if (and id (not (minusp id))) (unload_dialog id))
      (vl-file-delete fn))
    (setq res 'fail))
  res)

;;---------------------------------------------------------------------------
;;  Roundabout geometry
;;---------------------------------------------------------------------------
;; local leg frame : x along u from O, y to the left of u
(defun rp:rb-lp (O u nv x y) (rp:v+ (rp:v+ O (rp:v* u x)) (rp:v* nv y)))

;; Fillet of radius r between the leg edge (side +1 left / -1 right of u, at hw
;; from the leg CL through O) and the inscribed circle R (external tangency).
;; Returns (edge-tangent circle-tangent centre r s) or nil
(defun rp:rb-fil (O u hw Rin rfl side / nv s c)
  (if (> Rin hw)
    (progn
      (setq nv (rp:lnorm u)
            s  (sqrt (max 0.0 (- (* (+ Rin rfl) (+ Rin rfl)) (* (+ hw rfl) (+ hw rfl)))))
            c  (rp:rb-lp O u nv s (* side (+ hw rfl))))
      (list (rp:rb-lp O u nv s (* side hw))
            (rp:v+ O (rp:v* (rp:v- c O) (/ Rin (+ Rin rfl))))
            c rfl s))))

;; Corner between leg li (entry fillet, left of its u) and the next leg lj
;; anticlockwise (exit fillet, right of its u). Radii shrink until they fit.
;; Returns (fi fj sweep-of-the-circle-arc) or nil
(defun rp:rb-corner (O R li lj rE rX fac / ui uj span k ok fi fj di dj)
  (setq ui   (nth 3 li) uj (nth 3 lj)
        span (rp:mod2pi (- (angle '(0.0 0.0) uj) (angle '(0.0 0.0) ui)))
        k    0)
  (if (< span 1e-6) (setq span (* 2.0 pi)))
  (while (and (not ok) (< k 10))
    (setq fi (rp:rb-fil O ui (nth 4 li) R rE 1.0)
          fj (rp:rb-fil O uj (nth 4 lj) R rX -1.0))
    (if (and fi fj)
      (progn
        (setq di (rp:mod2pi (- (angle O (cadr fi)) (angle '(0.0 0.0) ui)))
              dj (rp:mod2pi (- (angle O (cadr fj)) (angle '(0.0 0.0) ui))))
        (if (and (> di 1e-6) (< di dj) (< dj (- span 1e-6))) (setq ok T))))
    (if (not ok)
      (setq rE (if (< k 8) (* 0.75 rE) 0.0)
            rX (if (< k 8) (* 0.75 rX) 0.0)
            k  (1+ k))))
  (if ok (list fi fj (- dj di))))

;; Outer kerb line of a corner : ((point bulge) ...)
(defun rp:rb-path (O fi fj sw / v)
  (if (> (nth 3 fi) 1e-9)
    (setq v (list (list (car fi) (rp:minarc-bulge (caddr fi) (car fi) (cadr fi))))))
  (setq v (append v (list (list (cadr fi) (rp:tan (* 0.25 sw))))))
  (if (> (nth 3 fj) 1e-9)
    (setq v (append v (list (list (cadr fj) (rp:minarc-bulge (caddr fj) (cadr fj) (car fj)))))))
  (append v (list (list (car fj) 0.0))))

;; Legs ((obj ename dirS u hw kind name width) ...) sorted anticlockwise, or nil
;; when two legs are closer than 25 deg. Side roads must start near the centre.
(defun rp:rb-legs (mobj me mlen dJ O R rE hwm brs fac / legs dd bo ps pe l2 dn s near n k ok)
  (setq dd   (+ R (* 2.0 rE))
        legs (list (list mobj me 1 (rp:unit2 O (rp:opt mobj (min mlen (+ dJ dd)) 0.0)) hwm "M" "" 0.0)
                   (list mobj me -1 (rp:unit2 O (rp:opt mobj (max 0.0 (- dJ dd)) 0.0)) hwm "M" "" 0.0)))
  (foreach b brs
    (setq bo (vlax-ename->vla-object (car b))
          ps (rp:p2 (vlax-curve-getStartPoint bo))
          pe (rp:p2 (vlax-curve-getEndPoint bo))
          l2 (vlax-curve-getDistAtParam bo (vlax-curve-getEndParam bo))
          near (<= (distance ps O) (distance pe O))
          dn (if near (distance ps O) (distance pe O)))
    (if (> dn (+ R (* 20.0 fac)))
      (princ (strcat "\n  Side road " (cadr b) " skipped : it must start at the roundabout centre."))
      (progn
        (setq s (max (* 1.0 fac) (min l2 (- dd dn))))
        (setq legs (append legs (list (list bo (car b) 1
                                            (rp:unit2 O (rp:p2 (vlax-curve-getPointAtDist bo (if near s (- l2 s)))))
                                            (* 0.5 fac (caddr b)) "B" (cadr b) (caddr b))))))))
  (setq legs (vl-sort legs (function (lambda (a b) (< (angle '(0.0 0.0) (nth 3 a)) (angle '(0.0 0.0) (nth 3 b))))))
        n    (length legs) k 0 ok T)
  (repeat n
    (if (< (rp:mod2pi (- (angle '(0.0 0.0) (nth 3 (nth (rem (1+ k) n) legs))) (angle '(0.0 0.0) (nth 3 (nth k legs)))))
           (/ pi 7.2))
      (setq ok nil))
    (setq k (1+ k)))
  (if ok legs))

;; Side road : start at the inscribed circle (cut back or brought out to it)
(defun rp:rb-fit (e O R elev fac / ob ps pe c xs best bs s)
  (setq ob  (vlax-ename->vla-object e)
        ps (rp:p2 (vlax-curve-getStartPoint ob))
        pe (rp:p2 (vlax-curve-getEndPoint ob)))
  (if (> (distance ps O) (distance pe O))
    (progn (command "_.REVERSE" e "") (setq ps (rp:p2 (vlax-curve-getStartPoint ob)))))
  (cond
    ((< (distance ps O) (- R (* 0.001 fac)))
     (setq c  (vla-AddCircle *rp:spc* (rp:p3 O elev) R)
           xs (rp:inters ob c acExtendNone))
     (vla-Delete c)
     (foreach x xs
       (setq s (vlax-curve-getDistAtPoint ob x))
       (if (and s (or (null bs) (< s bs))) (setq bs s best x)))
     (if best (rp:break e (vlax-curve-getStartPoint ob) best)))
    ((> (distance ps O) (+ R (* 0.001 fac)))
     (if (< (abs (vla-GetBulge ob 0)) 1e-9)
       (vla-put-Coordinate ob 0 (rp:pt2var (rp:v+ O (rp:v* (rp:unit2 O ps) R))))
       (vla-AddVertex ob 0 (rp:pt2var (rp:v+ O (rp:v* (rp:unit2 O ps) R))))))))

;; Build a side road with the RDP settings (its start is a junction end)
(defun rp:rb-build (e name w ch / saved ok)
  (setq saved (mapcar '(lambda (x) (cons x (rp:val x)))
                      '("rname" "width" "endst" "report" "xsec" "chst" "ccarr" "clmode" "cmed" "keep" "jctl")))
  (foreach p (list (cons "ccarr" "0") (cons "clmode" "0") (cons "cmed" "0") (cons "keep" "0")
                   (cons "rname" name) (cons "width" (rtos w 2 3)) (cons "endst" "3") (cons "report" "0")
                   (cons "xsec" "0") (cons "chst" (rtos ch 2 3)) (cons "jctl" "2"))
    (rp:set (car p) (cdr p)))
  (setq *rp:presetcl* e
        ok (vl-catch-all-apply 'rp:run nil)
        *rp:presetcl* nil)
  (foreach x saved (rp:set (car x) (cdr x)))
  (if (or (vl-catch-all-error-p ok) (null (rp:xget e)))
    (progn (princ (strcat "\n  Side road " name " could not be built - skipped.")) nil)
    T))

;; Remove small objects of the through road inside the roundabout
(defun rp:rb-clear (obj O rad / en ob mn mx c n bb)
  (setq n 0)
  (foreach h (append (vlax-ldata-get obj "ROADPRO_ALL") (vlax-ldata-get obj "ROADPRO_MKMAN"))
    (if (and (setq en (handent h)) (entget en)
             (wcmatch (strcase (cdr (assoc 8 (entget en))))
                      "ROAD-MARKING*,ROAD-SIGN*,ROAD-DELINEATOR,ROAD-CHAINAGE,ROAD-CONC-JOINT,ROAD-CONE*,ROAD-BARRIER*,ROAD-KERB"))
      (progn
        (setq ob  (vlax-ename->vla-object en)
              bb (vl-catch-all-apply 'vla-GetBoundingBox (list ob 'mn 'mx)))
        (if (not (vl-catch-all-error-p bb))
          (progn
            (setq mn (vlax-safearray->list mn) mx (vlax-safearray->list mx)
                  c  (list (* 0.5 (+ (car mn) (car mx))) (* 0.5 (+ (cadr mn) (cadr mx)))))
            (if (and (< (distance c O) rad) (< (distance (rp:p2 mn) (rp:p2 mx)) (* 2.0 rad)))
              (progn (entdel en) (setq n (1+ n)))))))))
  n)

;; Closed ring (kerb line) of radius r
(defun rp:rb-ring (O r w lay elev / ob)
  (setq ob (rp:mkpl (list (list (rp:v+ O (list r 0.0)) 1.0) (list (rp:v+ O (list (- r) 0.0)) 1.0)) lay elev T))
  (vla-put-ConstantWidth ob w)
  ob)

;; Pattern hatch at about 10 x real size (falls back to SOLID)
(defun rp:pathatch (nm elev fac / h)
  (setq h (vl-catch-all-apply 'vla-AddHatch (list *rp:spc* acHatchPatternTypePreDefined nm :vlax-false)))
  (if (vl-catch-all-error-p h)
    (setq h (vla-AddHatch *rp:spc* acHatchPatternTypePreDefined "SOLID" :vlax-false))
    (vl-catch-all-apply 'vla-put-PatternScale
                        (list h (* fac 10.0 (if (= (getvar "MEASUREMENT") 1) 0.001 0.0254)))))
  (vla-put-Elevation h elev)
  h)

;; Splitter island : straight taper from w0 at the circle to wn at the nose
(defun rp:rb-w (x x0 xe w0 wn) (+ w0 (* (- wn w0) (/ (- x x0) (- xe x0)))))

;; Distance of the outer kerb line from the leg CL at x : approach edge hw, or
;; the entry / exit fillet f = (edge-tangent circle-tangent centre r s) near the circle
(defun rp:rb-ycurb (x f hw / r s)
  (if (and f (> (nth 3 f) 1e-9) (< x (nth 4 f)))
    (progn
      (setq r (nth 3 f) s (nth 4 f))
      (+ hw r (- (sqrt (max 0.0 (- (* r r) (* (- s x) (- s x))))))))
    hw))

;; Splitter island half width on one side at x : fills the flare so that the
;; entry / exit keeps the lane width We, never less than the straight taper,
;; never closer than 3 m to the kerb, never under wn
(defun rp:rb-yisl (x f hw We x0 xe w0 wn fac / yc)
  (setq yc (rp:rb-ycurb x f hw))
  (max wn (min (- yc (* 3.0 fac)) (max (rp:rb-w x x0 xe w0 wn) (- yc We)))))

;; One piece of a splitter island from xa to xb (nose = round end at xb).
;; fE / fX = entry / exit fillet of this leg, We = entry lane width
(defun rp:rb-island (O u x0 xe w0 wn xa xb nose painted elev fac fE fX hw We / nv k x pts ob h bnd yl yr cy rad)
  (setq nv (rp:lnorm u) k 0)
  (repeat 13
    (setq x   (+ xa (* (- xb xa) (/ k 12.0)))
          pts (cons (rp:rb-lp O u nv x (- (rp:rb-yisl x fX hw We x0 xe w0 wn fac))) pts)
          k   (1+ k)))
  (if nose
    (progn
      (setq yl  (rp:rb-yisl xb fE hw We x0 xe w0 wn fac)
            yr  (rp:rb-yisl xb fX hw We x0 xe w0 wn fac)
            cy  (* 0.5 (- yl yr))
            rad (* 0.5 (+ yl yr))
            k   1)
      (repeat 7
        (setq pts (cons (rp:rb-lp O u nv (+ xb (* rad (sin (* pi (/ k 8.0))))) (- cy (* rad (cos (* pi (/ k 8.0)))))) pts)
              k   (1+ k)))))
  (setq k 12)
  (repeat 13
    (setq x   (+ xa (* (- xb xa) (/ k 12.0)))
          pts (cons (rp:rb-lp O u nv x (rp:rb-yisl x fE hw We x0 xe w0 wn fac)) pts)
          k   (1- k)))
  (setq pts (reverse pts))
  (if painted
    (progn
      (setq ob (rp:poly pts "ROAD-MARKING-FILL" elev))
      (vla-put-ConstantWidth ob (* 0.15 fac))
      (setq h   (rp:newhatch "ANSI31" nil elev)
            bnd (rp:poly pts "ROAD-MARKING" elev))
      (vla-put-Layer h "ROAD-MARKING-FILL")
      (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-AppendOuterLoop (list h (rp:objarr (list bnd)))))
        (vla-Delete h)
        (progn
          (vl-catch-all-apply 'vla-put-PatternScale (list h (* 0.35 fac)))
          (vl-catch-all-apply 'vla-put-PatternAngle (list h (+ (angle '(0.0 0.0) u) (* 0.25 pi))))
          (vla-Evaluate h)))
      (vla-Delete bnd))
    (progn
      (setq ob (rp:poly pts "ROAD-ISLAND" elev))
      (vla-put-ConstantWidth ob (* 0.15 fac))
      (rp:solidfill (rp:poly pts "ROAD-ISLAND" elev) nil "ROAD-KERB" elev))))

;; Zebra crossing across a leg at x = xc, kerb to kerb (yr right, yl left), 3 m wide
(defun rp:rb-zebra (O u xc yr yl elev fac / nv y)
  (setq nv (rp:lnorm u) y (+ (- yr) (* 0.25 fac)))
  (while (< (+ y (* 0.5 fac)) yl)
    (rp:jmk (list (rp:rb-lp O u nv (- xc (* 1.5 fac)) y) (rp:rb-lp O u nv (+ xc (* 1.5 fac)) y)
                  (rp:rb-lp O u nv (+ xc (* 1.5 fac)) (+ y (* 0.5 fac))) (rp:rb-lp O u nv (- xc (* 1.5 fac)) (+ y (* 0.5 fac))))
            elev)
    (setq y (+ y fac))))

;; Broken yield line on the entry, along the circle from the splitter island
;; to the entry fillet (L8 type : 0.6 m mark / 0.3 m gap, 0.3 m wide)
(defun rp:rb-yield (O u R tc w0 elev fac / ry a0 da len t0 a e)
  (setq ry  (+ R (* 0.25 fac))
        a0  (+ (angle '(0.0 0.0) u) (rp:asin (min 0.99 (/ (+ w0 (* 0.3 fac)) ry))))
        da  (rp:mod2pi (- (angle O tc) a0))
        len (* ry da)
        t0  0.0)
  (if (< da pi)
    (while (< (+ t0 (* 0.6 fac)) len)
      (setq a (+ a0 (/ t0 ry)) e (+ a0 (/ (+ t0 (* 0.6 fac)) ry)))
      (rp:jmk (list (polar O a (- ry (* 0.15 fac))) (polar O e (- ry (* 0.15 fac)))
                    (polar O e (+ ry (* 0.15 fac))) (polar O a (+ ry (* 0.15 fac))))
              elev)
      (setq t0 (+ t0 (* 0.9 fac))))))

;; Give-way triangle in an entry lane (base at x, apex 3.75 m out)
(defun rp:rb-tri (O u x y elev fac / nv)
  (setq nv (rp:lnorm u))
  (rp:jmk (list (rp:rb-lp O u nv x (- y (* 0.625 fac))) (rp:rb-lp O u nv x (+ y (* 0.625 fac)))
                (rp:rb-lp O u nv (+ x (* 3.75 fac)) y))
          elev))

;; Spiral lane line : from the middle of the circulatory roadway at the entry
;; (ts) out to the outer edge at the next exit (te), 150 mm solid
(defun rp:rb-spiral (O R Wc ts te elev fac / a0 da r0 r1 m k t0 a rs pa pb)
  (setq a0 (angle O ts)
        da (rp:mod2pi (- (angle O te) a0))
        r0 (- R (* 0.5 Wc))
        r1 (- R (* 0.4 fac))
        m  (max 8 (fix (/ (* da r0) fac)))
        k  0)
  (repeat (1+ m)
    (setq t0 (/ (float k) m)
          a  (+ a0 (* da t0))
          rs  (+ r0 (* (- r1 r0) t0))
          pa (cons (polar O a (- rs (* 0.075 fac))) pa)
          pb (cons (polar O a (+ rs (* 0.075 fac))) pb)
          k  (1+ k)))
  (rp:jmk (append (reverse pa) pb) elev))

;; Broken circulating lane line (3 m / 3 m) at radius r
(defun rp:rb-dashcircle (O r elev fac / a da e)
  (setq a 0.0 da (/ (* 3.0 fac) r))
  (while (< (+ a da) (* 2.0 pi))
    (setq e (+ a da))
    (rp:jmk (list (polar O a (- r (* 0.075 fac))) (polar O (* 0.5 (+ a e)) (- r (* 0.075 fac)))
                  (polar O e (- r (* 0.075 fac))) (polar O e (+ r (* 0.075 fac)))
                  (polar O (* 0.5 (+ a e)) (+ r (* 0.075 fac))) (polar O a (+ r (* 0.075 fac))))
            elev)
    (setq a (+ a (* 2.0 da)))))

;; ROUNDABOUT AHEAD : warning triangle with three anticlockwise arrows
(defun rp:icon-rbahead (c sz elev / cc k pts a)
  (rp:tri-sign c sz elev nil)
  (setq cc (list (car c) (- (cadr c) (* 0.03 sz))))
  (foreach a0 (list 0.0 (/ (* 2.0 pi) 3.0) (/ (* 4.0 pi) 3.0))
    (setq pts nil k 0)
    (repeat 7
      (setq pts (cons (list (polar cc (+ a0 (* 0.25 k)) (* 0.12 sz)) (* 0.03 sz) (* 0.03 sz)) pts) k (1+ k)))
    (rp:mkwpl (reverse pts) "ROAD-SIGN" elev)
    (setq a (+ a0 1.5))
    (rp:mkwpl (list (list (polar cc a (* 0.12 sz)) (* 0.09 sz) 0.0) (list (polar cc (+ a 0.45) (* 0.12 sz)) 0.0 0.0))
              "ROAD-SIGN" elev)))

(defun rp:rb-edgetxt (add jty fac)
  (cond ((= jty "1") (strcat (itoa (caddr add)) " traffic cones"))
        ((= jty "2") (strcat (rtos (/ (cadddr add) fac) 2 1) " m kerb stone"))
        (T (strcat (itoa (+ (car add) (cadr add))) " barricade units"))))

;;---------------------------------------------------------------------------
;;  Build a roundabout on road me at station dJ (drawing units).
;;  brs = side roads ((ename name width-m) ...) starting at the centre.
;;---------------------------------------------------------------------------
(defun rp:rbt-run (me dJ brs / mdata fac mobj mlen st0 hwm bgap bwid blen mo elev th sz R Wc Wa rE rX Ls Ws
                     lanes spir trav ped mark sgn spd idx std Rci O legs lg n i cr cn corners paths gaps bgl ss sa sb
                     sg st bo bd bgb bwb hwl u nv x0 xe w0 wn xc avail p wd k pts bnd c1 c2 h surfs isl jty add
                     path sd mt rbid lext kp li lj drw ch rows nsg a0 dm jrem key v x mk0 We fE fX yi yi2 yc xt
                     jh s0 bad legs2 chords te q1 q2)
  (setq mdata (rp:xget me)
        fac   (atof (rp:xv "FAC" mdata)))
  (if (<= fac 0.0) (setq fac 1.0))
  (setq mobj  (vlax-ename->vla-object me)
        mlen  (vlax-curve-getDistAtParam mobj (vlax-curve-getEndParam mobj))
        st0   (atof (rp:xv "CHST" mdata))
        hwm   (* 0.5 fac (atof (rp:xv "W" mdata)))
        bgap  (* fac (atof (rp:xv "BGAP" mdata)))
        bwid  (* fac (atof (rp:xv "BWID" mdata)))
        blen  (* fac (atof (rp:xv "BLEN" mdata)))
        mo    (* fac (atof (rp:xv "MO" mdata)))
        elev  (vla-get-Elevation mobj)
        th    (* fac (rp:num "txth"))
        sz    (* fac (rp:num "signsz"))
        R     (* fac (rp:num "rbr"))
        Wc    (* fac (rp:num "rbcw"))
        Wa    (* fac (rp:num "rbap"))
        rE    (* fac (rp:num "rbent"))
        rX    (* fac (rp:num "rbext"))
        Ls    (* fac (rp:num "rbspl"))
        Ws    (* fac (rp:num "rbspw"))
        lanes (if (= (rp:val "rblane") "1") 2 1)
        spir  (and (= lanes 2) (rp:on "rbspir"))
        trav  (rp:on "rbtrav")
        ped   (rp:on "rbped")
        mark  (rp:on "rbmark")
        sgn   (rp:on "rbsign")
        spd   (rp:num "rbspd")
        idx   (atoi (rp:val "rbstd"))
        std   (car (rp:rb-row idx))
        Rci   (- R Wc Wa)
        O     (car (rp:clpt mobj dJ))
        *rp:conc*  (rp:road-conc mobj)
        *rp:etype* (rp:etype mdata)
        *rp:hatches* nil)
  (if (<= blen 0.0) (setq blen (* 2.0 fac)))
  (cond
    ((<= R (+ hwm fac))
     (alert (strcat "The inscribed radius R = " (rtos (/ R fac) 2 2) " m is too small for this road (half width "
                    (rtos (/ hwm fac) 2 2) " m).\n\nRoundabout cancelled.")))
    ((and (not trav) (< Rci (* 0.5 fac)))
     (alert "The central island is too small : R - circulatory width - apron is below 0.5 m.\n\nRoundabout cancelled."))
    ((or (< (- dJ R rE (* 5.0 fac)) 0.0) (> (+ dJ R rE (* 5.0 fac)) mlen))
     (alert (strcat "The roundabout is too close to the end of the main road : it needs R + entry radius + 5 m ("
                    (rtos (/ (+ R rE (* 5.0 fac)) fac) 2 1) " m) on both sides of the centre.\n\nRoundabout cancelled.")))
    ((not (setq legs (rp:rb-legs mobj me mlen dJ O R rE hwm brs fac)))
     (alert "Two roads meet at less than 25 degrees - too sharp for a roundabout.\n\nRoundabout cancelled."))
    (T
     (setq mk0 (entlast) nsg 0 add (list 0 0 0 0.0)
           jty (if (= (rp:val "jcorner") "0") (rp:etype mdata) (itoa (1- (atoi (rp:val "jcorner"))))))
     ;; 1. side roads : centre line from the circle (a rebuild puts back the piece kept
     ;;    from the last build first)
     (foreach lg legs
       (if (= (nth 5 lg) "B")
         (progn
           (if (and *rp:replay* (setq jh (vlax-ldata-get (car lg) "RPJHEAD"))
                    (< (distance (rp:p2 (last (car jh))) (rp:p2 (vlax-curve-getStartPoint (car lg)))) (* 0.01 fac)))
             (rp:pl-prepend (car lg) jh))
           (rp:rb-fit (nth 1 lg) O R elev fac))))
     ;; available length of every leg, measured from the centre
     (setq legs (mapcar '(lambda (lg)
                           (append lg (list (if (= (nth 5 lg) "B")
                                              (+ R (vlax-curve-getDistAtParam (car lg) (vlax-curve-getEndParam (car lg))))
                                              (if (> (nth 2 lg) 0) (- mlen dJ) dJ)))))
                        legs))
     ;; 2. corners : entry fillet of leg i > circle arc > exit fillet of the next leg
     (setq corners (rp:rb-corners O R legs rE rX fac) n (length legs))
     ;; 2b. v3.6 : every side road starts where its two corner fillets end - nothing of
     ;;     it (surface, barricades, corridor, markings) is drawn inside the roundabout
     (setq i 0 legs2 nil bad nil)
     (foreach lg legs
       (setq s0 0.0)
       (if (= (nth 5 lg) "B")
         (progn
           (setq bo (car lg) x nil)
           (if (setq cr (caddr (nth i corners))) (setq x (cons (rp:sta bo (car (car cr))) x)))
           (if (setq cr (caddr (nth (rem (+ i n -1) n) corners))) (setq x (cons (rp:sta bo (car (cadr cr))) x)))
           (if x (setq s0 (min (apply 'max x) (* 0.8 (vlax-curve-getDistAtParam bo (vlax-curve-getEndParam bo))))))
           (if (> s0 (* 0.01 fac))
             (progn
               (setq k (rp:pl-head bo s0))
               (vlax-ldata-put bo "RPJHEAD" k)
               (setq h (rp:mkpl (mapcar 'list (car k) (cadr k)) "ROAD-CL" elev nil))
               (rp:props h "ROAD-CL" (rp:cl-ltype) (/ fac (getvar "LTSCALE")))
               (setvar "OSMODE" 0)
               (rp:break (nth 1 lg) (vlax-curve-getStartPoint bo) (vlax-curve-getPointAtDist bo s0))))
           (if (not (rp:rb-build (nth 1 lg) (nth 6 lg) (nth 7 lg) (/ s0 fac)))
             (setq bad T)
             (setq legs2 (append legs2 (list (append lg (list s0)))))))
         (setq legs2 (append legs2 (list (append lg (list s0))))))
       (setq i (1+ i)))
     (setq legs legs2)
     (if bad (setq corners (rp:rb-corners O R legs rE rX fac) n (length legs)))
     (setq *rp:conc* (rp:road-conc mobj)
           *rp:etype* (rp:etype mdata))
     ;; 3. through road : open both edges, clear edge units, centre units and small objects
     (foreach sg '(1.0 -1.0)
       (setq ss nil)
       (foreach cn corners
         (if (setq cr (caddr cn))
           (progn
             (setq lg (nth (car cn) legs))
             (if (and (= (nth 5 lg) "M") (= (* 1.0 (nth 2 lg)) sg)) (setq ss (cons (rp:sta mobj (car (car cr))) ss)))
             (setq lg (nth (cadr cn) legs))
             (if (and (= (nth 5 lg) "M") (= (* -1.0 (nth 2 lg)) sg)) (setq ss (cons (rp:sta mobj (car (cadr cr))) ss))))))
       (if (cdr ss)
         (progn
           (setq sa (apply 'min ss) sb (apply 'max ss))
           (setvar "OSMODE" 0)
           (if (setq bd (rp:edge-near (append (rp:opt mobj (* 0.5 (+ sa sb)) (* sg hwm)) (list elev)) fac nil))
             (rp:break bd (rp:opt mobj sa (* sg hwm)) (rp:opt mobj sb (* sg hwm))))
           ;; v3.6 : 1.5 units back so the last kept unit clears the corner run
           (setq k    (rp:jbar-band mobj sg hwm (+ hwm bgap bwid (* 0.5 fac)) (- sa (* 1.5 blen)) (+ sb (* 1.5 blen)))
                 jrem (cons (cons (if (> sg 0) "BL" "BR") k) jrem)
                 gaps (append gaps (list (list "M" sg sa sb) (list "G" sg sa sb)))))))
     (if (member (rp:xv "CTYPE" mdata) '("1" "2"))
       (rp:jbar-band mobj 1.0 (- mo bwid fac) (+ mo bwid fac) (- dJ R Ls (* 3.0 fac)) (+ dJ R Ls (* 3.0 fac))))
     (rp:rb-clear mobj O (+ R (* 0.5 fac)))
     ;; 4. side roads : edge pieces from the end of each fillet to the start of the side road
     (setq i 0)
     (foreach lg legs
       (if (= (nth 5 lg) "B")
         (foreach te (list (if (caddr (nth i corners)) (car (car (caddr (nth i corners)))))
                           (if (caddr (nth (rem (+ i n -1) n) corners)) (car (cadr (caddr (nth (rem (+ i n -1) n) corners))))))
           (if te
             (progn
               (setq p (rp:rb-s0pt lg te))
               (if (> (distance (rp:p2 te) p) (* 0.01 fac)) (rp:line (rp:p2 te) p "ROAD-EDGE" elev))))))
       (setq i (1+ i)))
     ;; 5. outer kerb line of every corner
     (foreach cn corners
       (if (setq cr (caddr cn))
         (progn
           (setq pts (rp:rb-path O (car cr) (cadr cr) (caddr cr)))
           (rp:mkpl pts "ROAD-EDGE" elev nil)
           (setq paths (append paths (list (list cn pts)))))
         (princ "\n  Warning: two legs are too close - one corner of the roundabout was not drawn.")))
     ;; 6. circulatory roadway (and the entry / exit flares)
     (if (and paths (= (length paths) (length corners)))
       (progn
         (setq pts nil chords nil)
         (foreach x paths
           (setq lg (nth (cadr (car x)) legs) cr (caddr (car x))
                 te (car (car (caddr (nth (cadr (car x)) corners)))))
           (setq pts (append pts (cadr x)
                             (if (= (nth 5 lg) "B")
                               (rp:rb-dpts (list (car (last (cadr x))) (rp:rb-s0pt lg (car (cadr cr))) (rp:rb-s0pt lg te) te) fac))))
           (if (= (nth 5 lg) "M") (setq chords (cons (list (nth 2 lg) (car (cadr cr)) te) chords))))
         (setq bnd (rp:mkpl pts "ROAD-SURFACE" elev T)
               c1  (vla-AddCircle *rp:spc* (rp:p3 O elev) (- R Wc))
               h   (rp:newhatch "SOLID" nil elev))
         (vla-put-Layer h "ROAD-SURFACE")
         (if (vl-catch-all-error-p
               (vl-catch-all-apply (function (lambda () (vla-AppendOuterLoop h (rp:objarr (list bnd)))
                                                        (vla-AppendInnerLoop h (rp:objarr (list c1)))))
                                   nil))
           (progn (vla-Delete h) (princ "\n  Warning: the roundabout surface hatch could not be created."))
           (progn
             (vla-Evaluate h)
             (vl-catch-all-apply 'vla-put-EntityTransparency (list h "50"))
             (rp:surf-color h)
             (setq surfs (cons h surfs))))
         (vla-Delete bnd)
         (vla-Delete c1)))
     ;; 6b. v3.6 : the through road surface and paved shoulders stop at the roundabout
     (if (= (length chords) 2) (rp:surf-cut mobj chords fac elev))
     ;; 7. truck apron and central island
     (if (and (> Wa 0.0) (> (- R Wc) (+ Rci (* 0.05 fac))))
       (progn
         (setq c1 (vla-AddCircle *rp:spc* (rp:p3 O elev) (- R Wc))
               c2 (vla-AddCircle *rp:spc* (rp:p3 O elev) (max (* 0.1 fac) Rci))
               h  (rp:pathatch "AR-CONC" elev fac))
         (vla-put-Layer h "ROAD-RB-APRON")
         (if (vl-catch-all-error-p
               (vl-catch-all-apply (function (lambda () (vla-AppendOuterLoop h (rp:objarr (list c1)))
                                                        (vla-AppendInnerLoop h (rp:objarr (list c2)))))
                                   nil))
           (vla-Delete h)
           (progn (vla-Evaluate h) (setq isl (cons h isl))))
         (vla-Delete c1)
         (vla-Delete c2)
         (setq isl (cons (rp:rb-ring O (- R Wc) (* 0.15 fac) "ROAD-ISLAND" elev) isl))))
     (if (> Rci (* 0.1 fac))
       (progn
         (setq c1 (vla-AddCircle *rp:spc* (rp:p3 O elev) Rci)
               h  (rp:newhatch (if trav "ANSI31" "SOLID") nil elev))
         (vla-put-Layer h (if trav "ROAD-MARKING-FILL" "ROAD-RB-ISLAND"))
         (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-AppendOuterLoop (list h (rp:objarr (list c1)))))
           (vla-Delete h)
           (progn
             (if trav (vl-catch-all-apply 'vla-put-PatternScale (list h (* 0.35 fac))))
             (vla-Evaluate h)
             (setq isl (cons h isl))))
         (vla-Delete c1)
         (setq isl (cons (rp:rb-ring O Rci (* 0.15 fac) (if trav "ROAD-MARKING-FILL" "ROAD-ISLAND") elev) isl))))
     ;; 8. splitter islands (fill the flare, keep the entry width), pedestrian
     ;;    crossings, KEEP RIGHT at the nose
     (setq We (* fac (if (= lanes 2) 8.0 4.6)) i 0)
     (foreach lg legs
       (setq u     (nth 3 lg) hwl (nth 4 lg) avail (nth 8 lg)
             fE    (car (caddr (nth i corners)))
             fX    (cadr (caddr (nth (rem (+ i n -1) n) corners)))
             x0    (+ R (* 0.5 fac))
             xe    (min (+ x0 Ls) (- avail (* 3.0 fac)))
             w0    (max (* 0.5 fac) (* 0.5 Ws))
             wn    (* 0.3 fac))
       (if (> (- xe x0) (* 2.0 fac))
         (progn
           (setq xc (if ped (min (- xe (* 3.0 fac)) (+ R (* 7.5 fac)))))
           (foreach pc (if xc
                         (list (list x0 (- xc (* 1.5 fac)) nil) (list (+ xc (* 1.5 fac)) xe T))
                         (list (list x0 xe T)))
             (if (> (- (cadr pc) (car pc)) (* 1.0 fac))
               (rp:rb-island O u x0 xe w0 wn (car pc) (cadr pc) (caddr pc) (= (rp:val "rbspt") "1") elev fac fE fX hwl We)))
           (if xc (rp:rb-zebra O u xc (rp:rb-ycurb xc fX hwl) (rp:rb-ycurb xc fE hwl) elev fac))
           (if sgn
             (progn
               (rp:icon-keepright (rp:v+ O (rp:v* u (+ xe (* 0.8 sz)))) (* 0.8 sz) elev)
               (setq nsg (1+ nsg))))))
       (setq i (1+ i)))
     ;; 9. markings : yield lines + triangles on every entry, circulating lane line
     (if mark
       (progn
         (setq i 0)
         (foreach lg legs
           (setq u   (nth 3 lg) hwl (nth 4 lg)
                 cr  (caddr (nth i corners))
                 fE  (car cr)
                 x0  (+ R (* 0.5 fac))
                 xe  (min (+ x0 Ls) (- (nth 8 lg) (* 3.0 fac)))
                 w0  (max (* 0.5 fac) (* 0.5 Ws))
                 wn  (* 0.3 fac)
                 xt  (+ R (* 3.4 fac)))
           (if cr
             (progn
               (setq yi  (if (> (- xe x0) (* 2.0 fac)) (rp:rb-yisl x0 fE hwl We x0 xe w0 wn fac) 0.0)
                     yi2 (if (> (- xe x0) (* 2.0 fac)) (rp:rb-yisl (min xt xe) fE hwl We x0 xe w0 wn fac) 0.0)
                     yc  (rp:rb-ycurb xt fE hwl))
               (rp:rb-yield O u R (cadr fE) yi elev fac)
               (foreach y (if (= lanes 2)
                            (list (+ yi2 (* 0.25 (- yc yi2))) (+ yi2 (* 0.75 (- yc yi2))))
                            (list (* 0.5 (+ yi2 yc))))
                 (rp:rb-tri O u (+ R (* 1.5 fac)) y elev fac))))
           (setq i (1+ i)))
         (if (= lanes 2)
           (if spir
             (foreach cn corners
               (if (setq cr (caddr cn)) (rp:rb-spiral O R Wc (cadr (car cr)) (cadr (cadr cr)) elev fac)))
             (rp:rb-dashcircle O (- R (* 0.5 Wc)) elev fac)))
         ;; v3.6 full marking : edge lines 0.30 m inside every kerb, inner edge line of the
         ;; circulatory roadway, entry lane arrows on every approach
         (foreach x paths (rp:rb-edgeline (cadr x) O elev fac))
         (rp:rb-ring O (+ (- R Wc) (* 0.375 fac)) (* 0.15 fac) "ROAD-MARKING-FILL" elev)
         (setq i 0)
         (foreach lg legs
           (setq u (nth 3 lg) hwl (nth 4 lg) nv (rp:lnorm u)
                 cr (caddr (nth i corners))
                 xt (+ R (* 0.5 fac) Ls (* 6.0 fac)))
           (if (and cr (< xt (- (nth 8 lg) (* 4.0 fac))))
             (progn
               (setq fE (car cr) yc (rp:rb-ycurb xt fE hwl) yi (* 0.15 fac))
               (foreach y (if (= lanes 2)
                            (list (+ yi (* 0.25 (- yc yi))) (+ yi (* 0.75 (- yc yi))))
                            (list (* 0.5 (+ yi yc))))
                 (rp:arrow (rp:rb-lp O u nv xt y) (angle '(0.0 0.0) (rp:v* u -1.0)) fac elev))))
           (setq i (1+ i)))))
     ;; 10. signs : GIVE WAY and ROUNDABOUT AHEAD on every approach (right side)
     (if sgn
       (progn
         (setq wd (* fac (nth 4 (rp:hds-row spd))) i 0)
         (foreach lg legs
           (setq u  (nth 3 lg) hwl (nth 4 lg) nv (rp:lnorm u) avail (nth 8 lg)
                 fE (car (caddr (nth i corners)))
                 p  (rp:rb-lp O u nv (+ R (* 4.0 fac)) (+ (rp:rb-ycurb (+ R (* 4.0 fac)) fE hwl) bgap bwid fac (* 0.5 sz))))
           (rp:icon-giveway p sz elev)
           (setq nsg (1+ nsg))
           (if (< (+ R (* 4.0 fac) wd) (- avail (* 2.0 fac)))
             (progn
               (rp:icon-rbahead (rp:rb-lp O u nv (+ R (* 4.0 fac) wd) (+ hwl bgap bwid fac (* 0.5 sz))) sz elev)
               (setq nsg (1+ nsg))))
           (setq i (1+ i)))))
     ;; 11. edge treatment round the corners (barricades / cones / kerb)
     (if (rp:on "jbar")
       (foreach x paths
         (setq cn   (car x) cr (caddr cn) li (nth (car cn) legs) lj (nth (cadr cn) legs)
               q1   (if (= (nth 5 li) "B") (rp:rb-s0pt li (car (car cr))) (rp:v+ (car (car cr)) (rp:v* (nth 3 li) blen)))
               q2   (if (= (nth 5 lj) "B") (rp:rb-s0pt lj (car (cadr cr))) (rp:v+ (car (cadr cr)) (rp:v* (nth 3 lj) blen)))
               pts  (append (if (> (distance q1 (car (car cr))) (* 0.01 fac)) (list (list q1 0.0)))
                            (cadr x)
                            (if (> (distance q2 (car (cadr cr))) (* 0.01 fac)) (list (list q2 0.0))))
               path (rp:mkpl pts "ROAD-JUNCTION" elev nil)
               *rp:len* (vlax-curve-getDistAtParam path (vlax-curve-getEndParam path))
               sd   (if (> (rp:lat path O) 0.0) -1.0 1.0)
               k    (rp:edge-run path *rp:len* (* sd bgap) (* sd (+ bgap bwid)) jty blen fac elev)
               add  (mapcar '+ add k))
         (vla-Delete path)))
     ;; 12. draw order : surfaces at the back, apron and island over the through road
     (if *rp:hatches* (rp:toback *rp:hatches*))
     (if surfs (rp:toback surfs))
     (if isl (rp:order-ss (mapcar 'vlax-vla-object->ename isl) "_F"))
     (if (and sgn (not trav) (> Rci (* 2.0 fac)))
       (foreach lg legs
         (rp:chevron (rp:v+ O (rp:v* (nth 3 lg) (- Rci (* 0.8 fac)))) (angle '(0.0 0.0) (rp:lnorm (nth 3 lg))) (* 0.8 sz) elev)
         (setq nsg (1+ nsg))))
     ;; 13. labels : fillet radii, roundabout data, ICD dimension
     (setq rbid (strcat "RB" (itoa (1+ (length (vlax-ldata-get mobj "ROADPRO_RBT"))))))
     (foreach x paths
       (setq cr (caddr (car x)))
       (foreach f (list (car cr) (cadr cr))
         (if (> (nth 3 f) (* 0.01 fac))
           (rp:jrmark (rp:pl-sample (list (car f) (cadr f)) (list (rp:minarc-bulge (caddr f) (car f) (cadr f)) 0.0) nil (* 0.5 fac))
                      (caddr f) (nth 3 f) fac th elev))))
     (setq mt (vla-AddMText *rp:spc* (rp:p3 O elev) (max (* 14.0 fac) (* 1.5 Rci))
                (strcat "ROUNDABOUT " rbid "\\P" std
                        "\\PICD " (rtos (/ (* 2.0 R) fac) 2 2) " m  (R " (rtos (/ R fac) 2 2) " m)"
                        "\\PCIRCULATORY " (rtos (/ Wc fac) 2 2) " m" (if (> Wa 0.0) (strcat "   APRON " (rtos (/ Wa fac) 2 2) " m") "")
                        "\\PENTRY R " (rtos (/ rE fac) 2 1) "   EXIT R " (rtos (/ rX fac) 2 1)
                        "\\P" (itoa lanes) " LANE(S)   " (rtos spd 2 0) " km/h")))
     (vla-put-Height mt (* 0.55 th))
     (vla-put-AttachmentPoint mt acAttachmentPointMiddleCenter)
     (vla-put-InsertionPoint mt (rp:p3 (if (> Rci (* 7.0 fac)) O (rp:v+ O (list 0.0 (+ R (* 10.0 fac))))) elev))
     (vla-put-Layer mt "ROAD-ROUNDABOUT")
     (setq a0 (+ (angle '(0.0 0.0) (nth 3 (car legs)))
                 (* 0.5 (rp:mod2pi (- (angle '(0.0 0.0) (nth 3 (cadr legs))) (angle '(0.0 0.0) (nth 3 (car legs))))))))
     (setq dm (vl-catch-all-apply 'vla-AddDimDiametric
                                  (list *rp:spc* (rp:p3 (polar O a0 R) elev) (rp:p3 (polar O (+ a0 pi) R) elev) (* 3.0 fac))))
     (if (not (vl-catch-all-error-p dm))
       (progn
         (vla-put-Layer dm "ROAD-ROUNDABOUT")
         (vl-catch-all-apply 'vla-put-TextHeight (list dm (* 0.6 th)))
         (vl-catch-all-apply 'vla-put-ArrowheadSize (list dm (* 0.4 th)))
         (vl-catch-all-apply 'vla-put-TextOverride (list dm (strcat "ICD <>")))))
     ;; 14. corner records (sidewalks, walkways, drains, utilities wrap round), gaps
     (setq lext (* 80.0 fac))
     (foreach x paths
       (setq cn  (car x) cr (caddr cn) li (nth (car cn) legs) lj (nth (cadr cn) legs)
             kp  (append (list (append (rp:v+ (car (car cr)) (rp:v* (nth 3 li) lext)) '(0.0)))
                         (mapcar '(lambda (v) (list (car (car v)) (cadr (car v)) (cadr v))) (cadr x))
                         (list (append (rp:v+ (car (cadr cr)) (rp:v* (nth 3 lj) lext)) '(0.0))))
             drw (cond ((rp:has-corr (car li)) 1) ((rp:has-corr (car lj)) 2) (T 1)))
       (rp:ldata-add (car li) "ROADPRO_JCORN"
                     (list rbid (* 1.0 (nth 2 li)) (rp:sta (car li) (car (car cr))) (* -1.0 (nth 2 li)) kp O
                           (if (= drw 1) 1 0) "ALL" "A" (vla-get-Handle (car lj))
                           (* -1.0 (nth 2 lj)) (rp:sta (car lj) (car (cadr cr))) (* -1.0 (nth 2 lj))))
       (rp:ldata-add (car lj) "ROADPRO_JCORN"
                     (list rbid (* -1.0 (nth 2 lj)) (rp:sta (car lj) (car (cadr cr))) (* -1.0 (nth 2 lj)) (rp:kp-rev kp) O
                           (if (= drw 2) 1 0) "ALL" "A" (vla-get-Handle (car li))
                           (* 1.0 (nth 2 li)) (rp:sta (car li) (car (car cr))) (* -1.0 (nth 2 li)))))
     (setq x (+ R (* 0.5 fac) Ls (* 2.0 fac)))
     (rp:ldata-addl mobj "ROADPRO_MKGAP"
                    (append gaps (list (list "C" 0.0 (- dJ x) (+ dJ x))
                                       (list "S" 1.0 (- dJ x (* 30.0 fac)) (+ dJ x (* 30.0 fac))))))
     (foreach lg legs
       (if (= (nth 5 lg) "B")
         (rp:ldata-addl (car lg) "ROADPRO_MKGAP"
                        (append (cdr (assoc (nth 1 lg) bgl))
                                (list (list "C" 0.0 0.0 (+ Ls (* 2.5 fac))) (list "S" 1.0 0.0 (+ Ls (* 30.0 fac))))))))
     ;; 15. setting-out and the roundabout record on the through road
     (setq ch   (rp:chfmt (+ st0 (/ dJ fac)))
           rows (list (list rbid "CENTRE" ch (rtos (/ (car O) fac) 2 3) (rtos (/ (cadr O) fac) 2 3)))
           k    0)
     (foreach x paths
       (setq k (1+ k) cr (caddr (car x)))
       (foreach q (list (list "TE-IN" (car (car cr))) (list "TC-IN" (cadr (car cr)))
                        (list "TC-OUT" (cadr (cadr cr))) (list "TE-OUT" (car (cadr cr))))
         (setq rows (append rows (list (list (strcat rbid "-" (itoa k)) (car q)
                                             (rp:chfmt (+ st0 (/ (rp:sta mobj (cadr q)) fac)))
                                             (rtos (/ (car (cadr q)) fac) 2 3) (rtos (/ (cadr (cadr q)) fac) 2 3)))))))
     (rp:ldata-add mobj "ROADPRO_RBT"
                   (list rbid std ch (rtos (/ (* 2.0 R) fac) 2 2) (rtos (/ Wc fac) 2 2) (rtos (/ Wa fac) 2 2)
                         (rtos (/ rE fac) 2 1) (rtos (/ rX fac) 2 1) (rtos spd 2 0) (itoa lanes) (itoa (length legs))
                         (rtos (/ Ls fac) 2 1) (rtos (/ Ws fac) 2 2)
                         (if trav "mountable (traversable), painted" (strcat "raised, landscaped, R " (rtos (/ Rci fac) 2 2) " m"))
                         rows nsg
                         (if (rp:on "jbar") (strcat (rp:rb-edgetxt add jty fac) " round the corners") "no edge treatment round the corners")
                         (if ped "yes" "no")
                         (cond (spir "spiral") ((= lanes 2) "concentric") (T "-"))))
     ;; barricade counts of the through road
     (foreach x jrem
       (setq key   (car x)
             v     (rp:pairget (rp:xv key mdata))
             mdata (append (vl-remove-if '(lambda (y) (= (car y) key)) mdata)
                           (list (cons key (rp:pair (list (max 0 (- (car v) (cadr x))) (max 0 (- (cadr v) (caddr x))))))))))
     (rp:xput me mdata)
     ;; 16. operation log (rebuild / live update), links, refresh
     (rp:ops-add mobj "R" (list (+ st0 (/ dJ fac))
                                (mapcar '(lambda (lg) (list (vla-get-Handle (car lg)) (nth 6 lg) (nth 7 lg)))
                                        (vl-remove-if-not '(lambda (lg) (= (nth 5 lg) "B")) legs))))
     (foreach lg legs (if (= (nth 5 lg) "B") (rp:set-jmain (nth 1 lg) mobj)))
     (if (vlax-ldata-get mobj "ROADPRO_MKMAN") (rp:mark-run me))
     (foreach lg legs
       (if (and (= (nth 5 lg) "B") (vlax-ldata-get (car lg) "ROADPRO_MKMAN")) (rp:mark-run (nth 1 lg))))
     (rp:refresh-corr me)
     (foreach lg legs (if (= (nth 5 lg) "B") (rp:refresh-corr (nth 1 lg))))
     (rp:track me mk0)
     (princ (strcat "\n  Roundabout " rbid " (" std ") at CH " ch " : ICD " (rtos (/ (* 2.0 R) fac) 2 2)
                    " m, " (itoa (length legs)) " legs, " (itoa lanes) " circulating lane(s)."))
     (princ "\n  Run RDR on the main road for the roundabout report and setting-out.")))
  (princ))

;; v3.6 : white edge line (150 mm, 0.30 m inside the kerb) along a roundabout kerb path
(defun rp:rb-edgeline (vl O elev fac / kp mid pref k1 k2 p1 p2)
  (setq kp   (mapcar '(lambda (v) (list (car (car v)) (cadr (car v)) (cadr v))) vl)
        mid  (car (nth (/ (length vl) 2) vl))
        pref (rp:v+ O (rp:v* (rp:v- mid O) 20.0))
        k1   (rp:k-off kp (* 0.30 fac) pref elev)
        k2   (rp:k-off kp (* 0.45 fac) pref elev))
  (if (and k1 k2)
    (progn
      (setq p1 (rp:pl-sample (car k1) (cadr k1) nil (* 0.5 fac))
            p2 (rp:pl-sample (car k2) (cadr k2) nil (* 0.5 fac)))
      (rp:solidfill (rp:poly (append p1 (reverse p2)) "ROAD-MARKING" elev) nil "ROAD-MARKING-FILL" elev))))

;; v3.6 roundabout helpers ----------------------------------------------------
;; corners of the roundabout : ((i j (fi fj sweep)) ...)
(defun rp:rb-corners (O R legs rE rX fac / n i out)
  (setq n (length legs) i 0)
  (repeat n
    (setq out (append out (list (list i (rem (1+ i) n)
                                      (rp:rb-corner O R (nth i legs) (nth (rem (1+ i) n) legs) rE rX fac))))
          i   (1+ i)))
  out)

;; start of side road lg on the side of point te
(defun rp:rb-s0pt (lg te / bo)
  (setq bo (car lg) *rp:len* (vlax-curve-getDistAtParam bo (vlax-curve-getEndParam bo)))
  (rp:offpt bo 0.0 (* (if (> (rp:lat bo te) 0.0) 1.0 -1.0) (nth 4 lg))))

;; middle points of a run a > b > c > d as ((pt bulge) ...), without repeats (b c only)
(defun rp:rb-dpts (run fac / out p)
  (setq p (car run))
  (foreach q (list (cadr run) (caddr run))
    (if (> (distance (rp:p2 q) (rp:p2 p)) (* 0.01 fac)) (setq out (append out (list (list (rp:p2 q) 0.0))) p q)))
  out)

;; Cut the through road surface (and its paved shoulders) between two chords
;; ((side p-left/right p-other) ...) - side -1 towards the start, +1 towards the end
(defun rp:surf-cut (mobj chords fac elev / sL sR c a b cuts hs len pcs s0 l0 r0 hw data pat sc h k pl pr bnd)
  (setq data (rp:xget (vlax-vla-object->ename mobj))
        hw   (* 0.5 fac (atof (rp:xv "W" data)))
        len  (vlax-curve-getDistAtParam mobj (vlax-curve-getEndParam mobj))
        *rp:len* len)
  (foreach c chords
    (setq pl (if (> (rp:lat mobj (cadr c)) 0.0) (cadr c) (caddr c))
          pr (if (> (rp:lat mobj (cadr c)) 0.0) (caddr c) (cadr c)))
    (if (< (car c) 0) (setq a (list (rp:sta mobj pl) (rp:sta mobj pr))) (setq b (list (rp:sta mobj pl) (rp:sta mobj pr)))))
  (if (and a b (not (vlax-curve-isClosed mobj)))
    (progn
      ;; paved shoulders inside the roundabout
      (rp:shld-cut mobj 1.0 (car a) (car b) fac elev)
      (rp:shld-cut mobj -1.0 (cadr a) (cadr b) fac elev)
      (setq *rp:len* len)
      ;; surface : complement of every roundabout on this road
      (setq cuts (vl-sort (append (vlax-ldata-get mobj "ROADPRO_SURFCUT") (list (list a b)))
                          '(lambda (x y) (< (car (car x)) (car (car y)))))
            hs   (vlax-ldata-get mobj "ROADPRO_SURF"))
      (if hs
        (progn
          (vlax-ldata-put mobj "ROADPRO_SURFCUT" cuts)
          (foreach x hs (if (and (setq k (handent x)) (entget k)) (entdel k)))
          (setq *rp:cset* (vlax-ldata-get mobj "ROADPRO_SET")
                pat (strcase (vl-string-trim " " (rp:cv "hpat")))
                sc  (rp:cn "hscl")
                *rp:cset* nil
                l0 0.0 r0 0.0 hs nil)
          (foreach c (append cuts (list (list (list len len) nil)))
            (if (and (> (- (car (car c)) l0) (* 0.01 fac)) (> (- (cadr (car c)) r0) (* 0.01 fac)))
              (progn
                (setq bnd (rp:poly (rp:dedupe (append (rp:side-pts mobj l0 (car (car c)) hw fac)
                                                      (reverse (rp:side-pts mobj r0 (cadr (car c)) (- hw) fac)))
                                              (* 0.001 fac))
                                   "ROAD-SURFACE" elev)
                      h   (rp:newhatch pat nil elev))
                (vla-put-Layer h "ROAD-SURFACE")
                (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-AppendOuterLoop (list h (rp:objarr (list bnd)))))
                  (vla-Delete h)
                  (progn
                    (if (/= (vla-get-PatternName h) "SOLID") (vl-catch-all-apply 'vla-put-PatternScale (list h sc)))
                    (vla-Evaluate h)
                    (vl-catch-all-apply 'vla-put-EntityTransparency (list h "50"))
                    (rp:surf-color h)
                    (setq hs (cons (vla-get-Handle h) hs))
                    (rp:toback (list h))))
                (vla-Delete bnd)))
            (if (cadr c) (setq l0 (car (cadr c)) r0 (cadr (cadr c)))))
          (vlax-ldata-put mobj "ROADPRO_SURF" hs))))))

;; points along the road side at offset o (+ left) from station a to b
(defun rp:side-pts (obj a b o fac / n i out)
  (setq n (max 1 (fix (+ 0.999999 (/ (abs (- b a)) (* 0.5 fac))))) i 0)
  (repeat (1+ n)
    (setq out (cons (rp:offpt obj (+ a (* (- b a) (/ (float i) n))) o) out) i (1+ i)))
  (reverse out))

;; Side road for ROADROUNDABOUT : drawn from the centre O, or selected
(defun rp:rb-getleg (O sd / prev e saved u)
  (princ (strcat "\n" (if (= sd 1) "LEFT" "RIGHT") " side road : "))
  (cond
    ;; v3.6 : automatic straight leg at 90 degrees to the through road (3-way / 4-way)
    ((= (rp:val "rblegm") "2")
     (setq u (rp:lnorm (cadr (rp:clpt *rp:rbmobj* *rp:rbdj*))) u (if (= sd 1) u (rp:v* u -1.0)))
     (princ (strcat "made automatically, " (rp:val "rbll") " m long."))
     (setq e (rp:mkpl (list (list (rp:p2 O) 0.0) (list (rp:v+ (rp:p2 O) (rp:v* u (* *rp:rbfac* (rp:num "rbll")))) 0.0))
                      "ROAD-CL" (caddr (vlax-curve-getStartPoint *rp:rbmobj*)) nil))
     (vlax-vla-object->ename e))
    ((= (rp:val "rblegm") "0")
      (setvar "PLINETYPE" 2)
      (setvar "PLINEWID" 0.0)
      (setq prev (entlast))
      (princ "draw its centre line from the roundabout centre outward (Enter to finish):")
      (setvar "CMDECHO" 1)
      (command "_.PLINE" "_non" (trans (list (car O) (cadr O) 0.0) 0 1))
      (while (> (getvar "CMDACTIVE") 0) (command pause))
      (setvar "CMDECHO" 0)
      (setq e (entlast))
      (if (or (equal e prev) (/= (cdr (assoc 0 (entget e))) "LWPOLYLINE")) nil e))
    (T
      (setq saved (rp:val "mode") *rp:presetcl* nil)
      (rp:set "mode" "1")
      (setq e (rp:get-centreline))
      (rp:set "mode" saved)
      e)))

(defun c:ROADROUNDABOUT (/ sel me data fac obj len st0 p dJ res legs b ch O)
  (rp:start) (rp:space) (rp:world) (rp:linetypes) (rp:layers)
  (setq *rp:presetcl* nil)
  (if (setq sel (rp:pick-road "\nSelect the MAIN road centre line - the roundabout is built on it (layer ROAD-CL): "))
    (progn
      (setq me   (car sel)
            data (rp:xget me)
            fac  (atof (rp:xv "FAC" data)))
      (if (<= fac 0.0) (setq fac 1.0))
      (setq obj (vlax-ename->vla-object me)
            len (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
            st0 (atof (rp:xv "CHST" data)))
      (initget "Chainage")
      (setq p (getpoint "\nPick the roundabout centre on the centre line or [Chainage]: "))
      (cond
        ((= p "Chainage")
         (if (setq ch (rp:dist (getstring "\nChainage of the roundabout centre (e.g. 0+250): ")))
           (setq dJ (* fac (- ch st0)))))
        (p (setq dJ (rp:sta obj (trans p 1 0)))))
      (cond
        ((null dJ) (princ "\nNo position given - roundabout cancelled."))
        ((or (< dJ 0.0) (> dJ len)) (alert "That chainage is outside the road."))
        (T
         (setq res (rp:rbdialog (strcat "Main road " (rp:xv "NAME" data) " at CH " (rp:chfmt (+ st0 (/ dJ fac)))
                                        "   |   width " (rp:xv "W" data) " m   |   traffic keeps right (anticlockwise)")
                                T))
         (if (= res 'fail) (princ "\nDialog not available - using the saved roundabout settings."))
         (if (/= res 'cancel)
           (progn
             (setq O (car (rp:clpt obj dJ)) *rp:rbmobj* obj *rp:rbdj* dJ *rp:rbfac* fac)
             (foreach sd (cond ((= (rp:val "rbleg") "1") '(1)) ((= (rp:val "rbleg") "2") '(2)) ((= (rp:val "rbleg") "3") '(1 2)))
               (if (setq b (rp:rb-getleg O sd))
                 (setq legs (append legs (list (list b (strcat (rp:val "rbbn") "-" (itoa (1+ (length legs)))) (rp:num "rbbw")))))))
             (rp:rbt-run me dJ legs))
           (princ "\nRoundabout cancelled."))))))
  (setq *rp:presetcl* nil)
  (rp:finish))

(defun c:RDRB () (c:ROADROUNDABOUT))

;;============================================================================
;;  v3.5  PAVEMENT : flexible (asphalt) or rigid CONCRETE
;;  Concrete pavement features : EARTHWORK, STONE BASE, CONCRETE slab and STEEL
;;  (dowel bars at the transverse joints, tie bars at the longitudinal joints,
;;  steel mesh for JRCP).  Plan : joint layout + label.  Cross section : the
;;  layers and the steel.  Report : neat quantities (no wastage).
;;  The pavement is stored with the road (rebuilds keep it). Change it on an
;;  existing road with ROADPAVEMENT (RDPV).
;;============================================================================
(setq *rp:pdefaults*
  '(("ptype" . "0")   ("pcont" . "0.25") ("pcong" . "C40")   ("pbaset" . "0.20")
    ("pbasen" . "CRUSHED STONE BASE")    ("peart" . "0.30")  ("pearn" . "EARTHWORK FILL 95% MDD")
    ("pjt" . "4.50")  ("pjl" . "4.00")   ("pjoint" . "1")    ("psh" . "1")
    ("pdowd" . "32")  ("pdowl" . "450")  ("pdows" . "300")
    ("ptied" . "16")  ("ptiel" . "800")  ("pties" . "750")
    ("pmesh" . "A393") ("pmeshk" . "6.16")))
(setq *rp:pkeys*    (mapcar 'car *rp:pdefaults*)
      *rp:defaults* (append *rp:defaults* *rp:pdefaults*))

;; concrete road ? (road snapshot *rp:cset* first, then the current settings)
(defun rp:conc-p () (if (member (rp:cv "ptype") '("1" "2")) T nil))

(defun rp:road-conc (obj / s)
  (setq s (vlax-ldata-get obj "ROADPRO_SET"))
  (if (member (cdr (assoc "ptype" s)) '("1" "2")) T nil))

;; light concrete colour on a surface hatch of a concrete road
(defun rp:surf-color (h / c)
  (if (and h *rp:conc*)
    (progn
      (setq c (vla-get-TrueColor h))
      (vla-SetRGB c 200 200 195)
      (vla-put-TrueColor h c))))

(defun rp:pave-summary ()
  (if (rp:conc-p)
    (strcat (if (= (rp:cv "ptype") "2") "JRCP" "JPCP") " concrete " (rtos (* 1000.0 (rp:cn "pcont")) 2 0) " mm "
            (rp:cv "pcong") " on " (rtos (* 1000.0 (rp:cn "pbaset")) 2 0) " mm stone base + "
            (rtos (* 1000.0 (rp:cn "peart")) 2 0) " mm earthwork, joints @ " (rtos (rp:cn "pjt") 2 2) " m")
    "Flexible asphalt pavement (layers in the cross-section dialog RDX)"))

(setq *rp:pdcl*
 (list
  "roadpave : dialog {"
  "  label = \"ROAD PRO  -  Pavement (asphalt / concrete)\";"
  "  : text { key = \"info\"; width = 100; }"
  "  : popup_list { key = \"ptype\"; label = \"Pavement type:\"; edit_width = 56; }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Concrete pavement layers\";"
  "      : edit_box { key = \"pcont\";  label = \"Concrete slab thickness (m):\"; edit_width = 7; }"
  "      : edit_box { key = \"pcong\";  label = \"Concrete grade:\";              edit_width = 7; }"
  "      : edit_box { key = \"pbaset\"; label = \"Stone base thickness (m):\";    edit_width = 7; }"
  "      : edit_box { key = \"pbasen\"; label = \"Stone base:\";                  edit_width = 30; }"
  "      : edit_box { key = \"peart\";  label = \"Earthwork thickness (m):\";     edit_width = 7; }"
  "      : edit_box { key = \"pearn\";  label = \"Earthwork:\";                   edit_width = 30; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Joints\";"
  "      : edit_box { key = \"pjt\";    label = \"Transverse joint spacing (m):\"; edit_width = 7; }"
  "      : edit_box { key = \"pjl\";    label = \"Max. slab width (m):\";          edit_width = 7; }"
  "      : toggle   { key = \"pjoint\"; label = \"Draw the joint layout on plan\"; }"
  "      : toggle   { key = \"psh\";    label = \"Concrete also on paved shoulders\"; }"
  "    }"
  "  }"
  "  : row {"
  "    : boxed_column {"
  "      label = \"Steel - dowel bars (transverse joints)\";"
  "      : edit_box { key = \"pdowd\"; label = \"Diameter (mm):\"; edit_width = 6; }"
  "      : edit_box { key = \"pdowl\"; label = \"Length (mm):\";   edit_width = 6; }"
  "      : edit_box { key = \"pdows\"; label = \"Spacing (mm):\";  edit_width = 6; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Steel - tie bars (longitudinal joints)\";"
  "      : edit_box { key = \"ptied\"; label = \"Diameter (mm):\"; edit_width = 6; }"
  "      : edit_box { key = \"ptiel\"; label = \"Length (mm):\";   edit_width = 6; }"
  "      : edit_box { key = \"pties\"; label = \"Spacing (mm):\";  edit_width = 6; }"
  "    }"
  "    : boxed_column {"
  "      label = \"Steel - mesh (JRCP only)\";"
  "      : edit_box { key = \"pmesh\";  label = \"Mesh type:\";      edit_width = 8; }"
  "      : edit_box { key = \"pmeshk\"; label = \"Weight (kg/m2):\"; edit_width = 6; }"
  "    }"
  "  }"
  "  : text { label = \"Asphalt (flexible) layers are set in the cross-section dialog (RDX). Quantities are neat - check them against the pavement design.\"; }"
  "  : text { label = \"Developed by https://www.exceltokml.com/\"; alignment = right; }"
  "  ok_cancel;"
  "  errtile;"
  "}"))

(defun rp:pdlg-modes (/ c)
  (setq c (/= (get_tile "ptype") "0"))
  (foreach k '("pcont" "pcong" "pbaset" "pbasen" "peart" "pearn" "pjt" "pjl" "pjoint" "psh"
               "pdowd" "pdowl" "pdows" "ptied" "ptiel" "pties")
    (mode_tile k (if c 0 1)))
  (foreach k '("pmesh" "pmeshk") (mode_tile k (if (= (get_tile "ptype") "2") 0 1))))

(defun rp:pdlg-accept (/ bad v)
  (if (/= (get_tile "ptype") "0")
    (foreach k '(("pcont" "Slab thickness") ("pbaset" "Stone base thickness" T) ("peart" "Earthwork thickness" T)
                 ("pjt" "Transverse joint spacing") ("pjl" "Slab width") ("pdowd" "Dowel diameter")
                 ("pdowl" "Dowel length") ("pdows" "Dowel spacing") ("ptied" "Tie bar diameter")
                 ("ptiel" "Tie bar length") ("pties" "Tie bar spacing") ("pmeshk" "Mesh weight" T))
      (if (not bad)
        (progn
          (setq v (rp:dist (get_tile (car k))))
          (if (or (null v) (if (caddr k) (< v 0.0) (<= v 0.0))) (setq bad k))))))
  (if bad
    (progn
      (set_tile "error" (strcat (cadr bad) (if (caddr bad) " must be zero or a positive number."
                                              " must be a number greater than zero.")))
      (mode_tile (car bad) 2))
    (progn
      (foreach k *rp:pkeys* (rp:set k (get_tile k)))
      (done_dialog 1))))

;; Pavement dialog (tiles from the road snapshot *rp:cset* when set)
(defun rp:pdialog (info / fn f id res)
  (setq fn (vl-filename-mktemp "roadpave.dcl"))
  (if (setq f (open fn "w"))
    (progn
      (foreach l *rp:pdcl* (write-line l f))
      (close f)
      (setq id (load_dialog fn))
      (if (and id (not (minusp id)) (new_dialog "roadpave" id))
        (progn
          (set_tile "info" info)
          (rp:fill "ptype" '("Flexible - asphalt layers (as set in RDX)"
                             "Concrete JPCP - jointed plain (dowels + tie bars)"
                             "Concrete JRCP - jointed reinforced (mesh + dowels + tie bars)"))
          (foreach k *rp:pkeys* (set_tile k (rp:cv k)))
          (rp:pdlg-modes)
          (action_tile "ptype" "(rp:pdlg-modes)")
          (action_tile "accept" "(rp:pdlg-accept)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq res (if (= (start_dialog) 1) 'ok 'cancel)))
        (setq res 'fail))
      (if (and id (not (minusp id))) (unload_dialog id))
      (vl-file-delete fn))
    (setq res 'fail))
  res)

;; Button in the RDP dialog
(defun rp:main-pave (/ r)
  (setq r (rp:pdialog "Pavement for new roads built with RDP (change an existing road with RDPV)."))
  (rp:main-pave-tiles)
  r)

(defun rp:main-pave-tiles () (set_tile "psum" (rp:pave-summary)))

;; Longitudinal joint offsets from the CL (+ left) : lane lines (and the
;; median / centre), or equal slabs not wider than pjl
(defun rp:pave-loffs (hw fac mo nl nr lw mw pjl / out k n)
  (cond
    ((and (> nl 0) (> nr 0) (> lw 0.0))
     (setq k 1)
     (repeat (1- nl) (setq out (cons (+ mo (* 0.5 mw) (* k lw)) out) k (1+ k)))
     (setq k 1)
     (repeat (1- nr) (setq out (cons (- mo (* 0.5 mw) (* k lw)) out) k (1+ k)))
     (if (> mw 0.0)
       (setq out (cons (+ mo (* 0.5 mw)) (cons (- mo (* 0.5 mw)) out)))
       (setq out (cons mo out))))
    (T
     (setq n (max 1 (fix (+ 0.999999 (/ (* 2.0 hw) pjl)))) k 1)
     (repeat (1- n) (setq out (cons (+ (- hw) (* k (/ (* 2.0 hw) n))) out) k (1+ k)))))
  (vl-sort out '<))

;; Concrete joint layout on plan (replaces the previous one of the road)
(defun rp:pave-run (e / data fac obj len hw elev bgap bwid recs gaps cg tpL tpR wpL wpR sh jt d eL eR n mark new
                        offs rg tx ang f th ip en)
  (setq data (rp:xget e) fac (atof (rp:xv "FAC" data)))
  (if (<= fac 0.0) (setq fac 1.0))
  (setq obj  (vlax-ename->vla-object e)
        *rp:cset* (vlax-ldata-get obj "ROADPRO_SET")
        len  (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
        *rp:len* len
        hw   (* 0.5 fac (atof (rp:xv "W" data)))
        elev (vla-get-Elevation obj)
        bgap (* fac (atof (rp:xv "BGAP" data)))
        bwid (* fac (atof (rp:xv "BWID" data)))
        recs (vlax-ldata-get obj "ROADPRO_TAPERS")
        gaps (vlax-ldata-get obj "ROADPRO_MKGAP")
        cg   (mapcar '(lambda (g) (list (nth 2 g) (nth 3 g)))
                     (vl-remove-if-not '(lambda (g) (member (car g) '("C" "G"))) gaps))
        th   (* 0.6 fac (rp:cn "txth")))
  (foreach hd (vlax-ldata-get obj "ROADPRO_PAVE")
    (if (and (setq en (handent hd)) (entget en)) (entdel en)))
  (setq mark (entlast) n 0)
  (if (and (rp:conc-p) (rp:con "pjoint"))
    (progn
      (setq sh  (if (rp:con "psh") bgap 0.0)
            jt  (* fac (rp:cn "pjt"))
            tpL (rp:taper-profs recs 1.0 fac)
            tpR (rp:taper-profs recs -1.0 fac)
            wpL (mapcar 'caddr (vl-remove-if-not '(lambda (g) (and (= (car g) "W") (= (cadr g) 1.0))) gaps))
            wpR (mapcar 'caddr (vl-remove-if-not '(lambda (g) (and (= (car g) "W") (= (cadr g) -1.0))) gaps))
            d   jt)
      ;; transverse contraction joints (dowelled)
      (while (< d (- len (* 0.5 fac)))
        (if (not (rp:mk-inside d cg))
          (progn
            (setq *rp:len* len
                  eL (+ (rp:edge-at tpL wpL hw d) sh)
                  eR (+ (rp:edge-at tpR wpR hw d) sh))
            (rp:line (rp:offpt obj d eL) (rp:offpt obj d (- eR)) "ROAD-CONC-JOINT" elev)
            (setq n (1+ n))))
        (setq d (+ d jt)))
      ;; longitudinal joints (tied)
      (setq offs (rp:pave-loffs hw fac (* fac (atof (rp:xv "MO" data))) (atoi (rp:xv "NL" data)) (atoi (rp:xv "NR" data))
                                (* fac (atof (rp:xv "LW" data))) (* fac (atof (rp:xv "MW" data))) (* fac (rp:cn "pjl"))))
      (foreach o offs
        (foreach rg (rp:mk-ranges 0.0 len cg)
          (setq *rp:len* len)
          (rp:cline obj (car rg) (cadr rg) 1.0 o nil nil 0.0 "ROAD-CONC-JOINT" elev fac)))
      ;; label along the road, outside the right edge
      (setq *rp:len* len
            d   (min (* 0.5 len) (* 25.0 fac))
            f   (rp:frame obj d)
            ang (angle '(0.0 0.0) (caddr f))
            ang (if (and (> ang (* 0.5 pi)) (<= ang (* 1.5 pi))) (+ ang pi) ang)
            ip  (rp:offpt obj d (- (+ hw bgap bwid (rp:corr-extra -1.0 fac bgap bwid) (* 3.0 fac))))
            tx  (rp:text (strcat (if (= (rp:cv "ptype") "2") "JRCP" "JPCP") " CONCRETE PAVEMENT "
                                 (rtos (* 1000.0 (rp:cn "pcont")) 2 0) " mm " (rp:cv "pcong")
                                 "  -  JOINTS @ " (rtos (rp:cn "pjt") 2 2) " m WITH DOWELS %%c" (rp:cv "pdowd") " x "
                                 (rp:cv "pdowl") " @ " (rp:cv "pdows") "  -  TIE BARS %%c" (rp:cv "ptied") " x "
                                 (rp:cv "ptiel") " @ " (rp:cv "pties"))
                         ip th "ROAD-CONC-JOINT" elev))
      (vla-put-Rotation tx ang)))
  (setq new (rp:since mark))
  (vlax-ldata-put obj "ROADPRO_PAVE" (mapcar '(lambda (x) (cdr (assoc 5 (entget x)))) new))
  (setq *rp:cset* nil)
  n)

;; Report rows : concrete quantities, or flexible layer volumes
(defun rp:pave-rows (obj data fac len w wtot tr / A Lm bg As Ac Af tc tb te Nt Wav Wj nlj Ll per Nd Wd Ntb Wt Am Wm rows)
  (setq *rp:cset* (vlax-ldata-get obj "ROADPRO_SET")
        Lm  (/ len fac)
        A   (+ (/ (* w len) fac fac) (if wtot wtot 0.0) (if tr (caddr tr) 0.0))
        bg  (atof (rp:xv "BGAP" data))
        As  (* 2.0 bg Lm))
  (if (rp:conc-p)
    (progn
      (setq tc  (rp:cn "pcont") tb (rp:cn "pbaset") te (rp:cn "peart")
            Ac  (+ A (if (rp:con "psh") As 0.0))
            Af  (+ A As)
            Nt  (fix (/ Lm (rp:cn "pjt")))
            Wav (if (> Lm 0.0) (/ A Lm) 0.0)
            Wj  (+ Wav (if (rp:con "psh") (* 2.0 bg) 0.0))
            nlj (length (rp:pave-loffs (* 0.5 (atof (rp:xv "W" data))) 1.0 (atof (rp:xv "MO" data))
                                       (atoi (rp:xv "NL" data)) (atoi (rp:xv "NR" data))
                                       (atof (rp:xv "LW" data)) (atof (rp:xv "MW" data)) (rp:cn "pjl")))
            Ll  (+ (* nlj Lm) (if (and (rp:con "psh") (> bg 0.0)) (* 2.0 Lm) 0.0))
            per (fix (/ (* Wj 1000.0) (rp:cn "pdows")))
            Nd  (* Nt per)
            Wd  (* Nd (/ (rp:cn "pdowl") 1000.0) (/ (* (rp:cn "pdowd") (rp:cn "pdowd")) 162.0))
            Ntb (fix (/ (* Ll 1000.0) (rp:cn "pties")))
            Wt  (* Ntb (/ (rp:cn "ptiel") 1000.0) (/ (* (rp:cn "ptied") (rp:cn "ptied")) 162.0))
            Am  (if (= (rp:cv "ptype") "2") (* 1.10 Ac) 0.0)
            Wm  (* Am (rp:cn "pmeshk")))
      (setq rows
        (list '("#" "CONCRETE PAVEMENT (NEAT QUANTITIES - ADD WASTAGE)")
              (list "Pavement type" (if (= (rp:cv "ptype") "2") "JRCP - jointed reinforced (mesh + dowels + tie bars)"
                                      "JPCP - jointed plain (dowels + tie bars)"))
              (list "Concrete slab" (strcat (rtos (* 1000.0 tc) 2 0) " mm " (rp:cv "pcong") ",  area " (rtos Ac 2 2)
                                           " m2,  volume " (rtos (* Ac tc) 2 2) " m3"))
              (list "Stone base" (strcat (rtos (* 1000.0 tb) 2 0) " mm " (rp:cv "pbasen") ",  volume " (rtos (* Af tb) 2 2) " m3"))
              (list "Earthwork" (strcat (rtos (* 1000.0 te) 2 0) " mm " (rp:cv "pearn") ",  formation " (rtos Af 2 2)
                                       " m2,  volume " (rtos (* Af te) 2 2) " m3"))
              (list "Transverse joints (dowelled)" (strcat (itoa Nt) " joints @ " (rtos (rp:cn "pjt") 2 2) " m,  total "
                                                          (rtos (* Nt Wj) 2 1) " m"))
              (list "Longitudinal joints (tied)" (strcat (itoa nlj) " line(s),  total " (rtos Ll 2 1) " m"))
              (list "Dowel bars" (strcat "dia " (rp:cv "pdowd") " x " (rp:cv "pdowl") " mm @ " (rp:cv "pdows") " mm :  "
                                        (itoa Nd) " nos,  " (rtos Wd 2 1) " kg"))
              (list "Tie bars" (strcat "dia " (rp:cv "ptied") " x " (rp:cv "ptiel") " mm @ " (rp:cv "pties") " mm :  "
                                      (itoa Ntb) " nos,  " (rtos Wt 2 1) " kg"))
              (if (> Am 0.0)
                (list "Steel mesh" (strcat (rp:cv "pmesh") " (" (rp:cv "pmeshk") " kg/m2) incl. 10% laps :  "
                                          (rtos Am 2 1) " m2,  " (rtos Wm 2 1) " kg")))
              (list "TOTAL steel" (strcat (rtos (/ (+ Wd Wt Wm) 1000.0) 2 3) " t"))
              (list "Joint sealant" (strcat (rtos (+ (* Nt Wj) Ll) 2 1) " m"))
              (list "Pavement note" "Neat quantities from the plan - confirm with the pavement design"))))
    (progn
      (setq rows (list '("#" "PAVEMENT - FLEXIBLE (NEAT QUANTITIES)")))
      (foreach l (rp:xlayers 1.0)
        (setq rows (append rows (list (list (car l) (strcat (rtos (* 1000.0 (cadr l)) 2 0) " mm,  area "
                                                            (rtos (+ A As) 2 2) " m2,  volume "
                                                            (rtos (* (+ A As) (cadr l)) 2 2) " m3"))))))))
  (setq *rp:cset* nil)
  (vl-remove nil rows))

;; Cross section : longitudinal joint positions in section coordinates
(defun rp:xjoints (hw fac / mw mo nl nr lw)
  (if *rp:xc*
    (setq mw (nth 0 *rp:xc*) mo (- (nth 1 *rp:xc*)) nl (nth 3 *rp:xc*) nr (nth 4 *rp:xc*) lw (nth 5 *rp:xc*))
    (setq mw 0.0 mo 0.0 nl 0 nr 0 lw 0.0))
  (mapcar '- (rp:pave-loffs hw fac mo nl nr lw mw (* fac (rp:cn "pjl")))))

;; Cross section : steel in the concrete slab + notes. Returns the note counter
(defun rp:xsteel (hw fac th lys xt yR ny / tc js y tl ln r sp x o ytx)
  (setq tc (cadr (car lys))
        js (rp:xjoints hw fac)
        tl (* 0.5 fac (/ (rp:cn "ptiel") 1000.0)))
  ;; tie bars across the longitudinal joints + sawn joint
  (foreach x js
    (setq y  (- (rp:ys x) (* 0.5 tc))
          ln (rp:xpl (list (list (- x tl) y) (list (+ x tl) y)) "ROAD-XSEC-STEEL" nil))
    (vla-put-ConstantWidth ln (* fac (/ (rp:cn "ptied") 1000.0)))
    (rp:xline (list x (rp:ys x)) (list x (- (rp:ys x) (* 0.3 tc))) "ROAD-XSEC"))
  ;; dowel bars, seen end-on at a transverse joint
  (setq r  (* 0.5 fac (/ (rp:cn "pdowd") 1000.0))
        sp (* fac (/ (rp:cn "pdows") 1000.0))
        x  (+ (- hw) (* 0.5 sp)))
  (while (< x hw)
    (setq o (vla-AddCircle *rp:spc* (rp:p3 (rp:xp x (- (rp:ys x) (* 0.5 tc))) 0.0) r))
    (vla-put-Layer o "ROAD-XSEC-STEEL")
    (rp:solidfill o nil "ROAD-XSEC-STEEL" 0.0)
    (setq x (+ x sp)))
  ;; steel mesh (JRCP) at one third of the depth
  (if (= (rp:cv "ptype") "2")
    (rp:xpl (rp:xsurf (* -0.33 tc)) "ROAD-XSEC-STEEL" nil))
  ;; notes
  (setq ytx (- (+ yR (* 0.8 fac)) (* ny 2.0 th)) ny (1+ ny))
  (rp:xline (list (- hw (* 0.5 sp)) (- (rp:ys (- hw (* 0.5 sp))) (* 0.5 tc))) (list (- xt (* 0.3 fac)) ytx) "ROAD-XSEC-THIN")
  (rp:xtext (strcat "DOWEL BARS %%c" (rp:cv "pdowd") " x " (rp:cv "pdowl") " @ " (rp:cv "pdows")
                    " c/c AT TRANSVERSE JOINTS EVERY " (rtos (rp:cn "pjt") 2 2) " m")
            (list xt ytx) th)
  (if js
    (progn
      (setq ytx (- (+ yR (* 0.8 fac)) (* ny 2.0 th)) ny (1+ ny))
      (rp:xline (list (car js) (- (rp:ys (car js)) (* 0.5 tc))) (list (- xt (* 0.3 fac)) ytx) "ROAD-XSEC-THIN")
      (rp:xtext (strcat "TIE BARS %%c" (rp:cv "ptied") " x " (rp:cv "ptiel") " @ " (rp:cv "pties")
                        " c/c AT THE SAWN LONGITUDINAL JOINTS")
                (list xt ytx) th)))
  (if (= (rp:cv "ptype") "2")
    (progn
      (setq ytx (- (+ yR (* 0.8 fac)) (* ny 2.0 th)) ny (1+ ny))
      (rp:xline (list (* -0.3 hw) (- (rp:ys (* -0.3 hw)) (* 0.33 tc))) (list (- xt (* 0.3 fac)) ytx) "ROAD-XSEC-THIN")
      (rp:xtext (strcat "STEEL MESH " (rp:cv "pmesh") " AT 1/3 DEPTH FROM THE TOP") (list xt ytx) th)))
  ny)

;; Surface hatches of road e : concrete colour or back to ByLayer
(defun rp:recolor (e / en o c)
  (foreach h (vlax-ldata-get (vlax-ename->vla-object e) "ROADPRO_ALL")
    (if (and (setq en (handent h)) (entget en)
             (= (cdr (assoc 0 (entget en))) "HATCH")
             (= (strcase (cdr (assoc 8 (entget en)))) "ROAD-SURFACE"))
      (progn
        (setq o (vlax-ename->vla-object en))
        (if *rp:conc*
          (rp:surf-color o)
          (progn
            (setq c (vla-get-TrueColor o))
            (vla-put-ColorMethod c acColorMethodByLayer)
            (vla-put-TrueColor o c)))))))

(defun c:ROADPAVEMENT (/ sel e obj data snap res new)
  (rp:start) (rp:space) (rp:world) (rp:linetypes) (rp:layers)
  (if (setq sel (rp:pick-road "\nSelect the road centre line (layer ROAD-CL): "))
    (progn
      (setq e    (car sel)
            obj  (vlax-ename->vla-object e)
            data (rp:xget e)
            snap (vlax-ldata-get obj "ROADPRO_SET"))
      (if (null snap) (setq snap (rp:snapshot-from-xdata data)))
      (setq *rp:cset* snap
            res (rp:pdialog (strcat "Road " (rp:xv "NAME" data) " - pavement of this road (also the default for new roads)."))
            *rp:cset* nil)
      (if (= res 'ok)
        (progn
          (setq new (append (mapcar '(lambda (k) (cons k (rp:val k))) *rp:pkeys*)
                            (vl-remove-if '(lambda (p) (member (car p) *rp:pkeys*)) snap)))
          (vlax-ldata-put obj "ROADPRO_SET" new)
          (setq *rp:conc* (rp:road-conc obj))
          (rp:recolor e)
          (rp:pave-run e)
          (rp:track e *rp:mk0*)
          (setq *rp:cset* new)
          (princ (strcat "\n  Pavement : " (rp:pave-summary) "."))
          (setq *rp:cset* nil)
          (princ "\n  RDR = report with the quantities,  RDX = cross section with the layers and the steel."))
        (princ "\nPavement cancelled."))))
  (rp:finish))

(defun c:RDPV () (c:ROADPAVEMENT))

;;============================================================================
;;  v3.5  OPERATION LOG, REPLAY, REBUILD AND LIVE UPDATE
;;  Every lane widening (RDW), taper (RDT), junction (RDJ) and roundabout is
;;  stored on its road with the settings used. A rebuild (RDB, RDER, RDC, or
;;  the LIVE update) draws the road again from its centre line and replays
;;  them in order : widenings, tapers, junctions and roundabouts - with their
;;  side roads and everything on them - come back automatically.
;;  LIVE : edit a road centre line (grips, MOVE, ROTATE, STRETCH, PEDIT ...)
;;  and the road, corridor, markings, junctions and roundabouts follow when the
;;  command ends. ROADLIVE (RDLIVE) switches it on / off.
;;============================================================================
(setq *rp:defaults* (append *rp:defaults* '(("live" . "1"))))

(defun rp:ops-add (obj typ extra)
  (vlax-ldata-put obj "ROADPRO_OPS"
                  (append (vlax-ldata-get obj "ROADPRO_OPS") (list (list typ (rp:snapshot) extra)))))

(defun rp:ldata-clear (e keepset / obj)
  (setq obj (vlax-ename->vla-object e))
  (foreach k (vlax-ldata-list obj)
    (if (and (wcmatch (strcase (car k)) "ROADPRO_*")
             (or (not keepset) (/= (strcase (car k)) "ROADPRO_SET")))
      (vlax-ldata-delete obj (car k)))))

;; does road obj have corridor items (sidewalks, walkways, drains, utilities, median) ?
(defun rp:has-corr (obj / r)
  (setq *rp:cset* (vlax-ldata-get obj "ROADPRO_SET")
        r         (and *rp:cset* (rp:corr-any))
        *rp:cset* nil)
  (if r T nil))

;; link a branch road to its main road (live update rebuilds the main road)
(defun rp:set-jmain (e mobj)
  (rp:xput e (append (vl-remove-if '(lambda (x) (= (car x) "JMAIN")) (rp:xget e))
                     (list (cons "JMAIN" (vla-get-Handle mobj))))))

;; branch roads joined to road e by its junctions and roundabouts
(defun rp:branches (e / out b)
  (foreach op (vlax-ldata-get (vlax-ename->vla-object e) "ROADPRO_OPS")
    (foreach h (cond ((= (car op) "J") (list (car (caddr op))))
                     ((= (car op) "R") (mapcar 'car (cadr (caddr op)))))
      (if (and h (setq b (handent h)) (entget b) (rp:xget b) (not (member b out)))
        (setq out (append out (list b))))))
  out)

;; road e and every road joined to it (recursively)
(defun rp:group (e / seen todo x)
  (setq todo (list e))
  (while todo
    (setq x (car todo) todo (cdr todo))
    (if (not (member x seen))
      (setq seen (append seen (list x)) todo (append todo (rp:branches x)))))
  seen)

;; top road of the group of e (follows the JMAIN links)
(defun rp:group-top (e / m k h)
  (setq k 0)
  (while (and (< k 20)
              (/= (setq h (rp:xv "JMAIN" (rp:xget e))) "")
              (setq m (handent h)) (entget m) (rp:xget m) (member e (rp:branches m)))
    (setq e m k (1+ k)))
  e)

(defun rp:geom-store (e / obj pd)
  (setq obj (vlax-ename->vla-object e) pd (rp:pldata obj))
  (vlax-ldata-put obj "ROADPRO_GEOM" (list (car pd) (cadr pd))))

(defun rp:geom-same (geo pd / ok)
  (setq ok (= (length (car geo)) (length (car pd))))
  (if ok (mapcar '(lambda (a b) (if (> (distance a b) 1e-6) (setq ok nil))) (car geo) (car pd)))
  (if ok (mapcar '(lambda (a b) (if (> (abs (- a b)) 1e-9) (setq ok nil))) (cadr geo) (cadr pd)))
  ok)

;; rigid move / rotation from vertices op to np (same bulges) : 4x4 matrix or nil
(defun rp:rigid (op ob np nb / k bd d a c s ok tx ty i)
  (if (and (= (length op) (length np)) (cdr op) (= (length ob) (length nb))
           (not (vl-some '(lambda (a b) (> (abs (- a b)) 1e-9)) ob nb)))
    (progn
      (setq bd 0.0 i 0 k 0)
      (foreach p op
        (if (> (setq d (distance (car op) p)) bd) (setq bd d k i))
        (setq i (1+ i)))
      (if (> bd 1e-9)
        (progn
          (setq a  (- (angle (car np) (nth k np)) (angle (car op) (nth k op)))
                c  (cos a)
                s  (sin a)
                ok T)
          (mapcar '(lambda (p q)
                     (if (> (distance q (list (+ (car (car np)) (* c (- (car p) (car (car op)))) (* -1.0 s (- (cadr p) (cadr (car op)))))
                                              (+ (cadr (car np)) (* s (- (car p) (car (car op)))) (* c (- (cadr p) (cadr (car op)))))))
                            (max 1e-4 (* 1e-7 bd)))
                       (setq ok nil)))
                  op np)
          (if ok
            (progn
              (setq tx (- (car (car np)) (- (* c (car (car op))) (* s (cadr (car op)))))
                    ty (- (cadr (car np)) (+ (* s (car (car op))) (* c (cadr (car op))))))
              (vlax-tmatrix (list (list c (- s) 0.0 tx) (list s c 0.0 ty) '(0.0 0.0 1.0 0.0) '(0.0 0.0 0.0 1.0))))))))))

;; after a rigid move of road e, move its branch centre lines the same way
;; (only those the user did not move together with it)
(defun rp:move-branches (e tr / o geo)
  (foreach b (cdr (rp:group e))
    (setq o   (vlax-ename->vla-object b)
          geo (vlax-ldata-get o "ROADPRO_GEOM"))
    (if (and geo (rp:geom-same geo (rp:pldata o)))
      (vla-TransformBy o tr))))

;; end of every build : version mark, geometry, live reactor
(defun rp:run-done (cl / obj)
  (setq obj (vlax-ename->vla-object cl))
  (vlax-ldata-put obj "ROADPRO_OPSV" 1)
  (rp:geom-store cl)
  (rp:live-attach cl))

;; Replay : bring the start of branch br back onto the main road CL (the main
;; road moved away). Returns T when the start was moved.
(defun rp:extend-start (br mobj tol / o ps u ln xs best bd d)
  (setq o  (vlax-ename->vla-object br)
        ps (vlax-curve-getStartPoint o))
  (if (> (distance (rp:p2 ps) (rp:p2 (rp:cpt mobj ps))) tol)
    (progn
      (setq u  (rp:unitv (vlax-curve-getFirstDeriv o (vlax-curve-getStartParam o)))
            ln (vla-AddLine *rp:spc* (rp:p3 (rp:v- (rp:p2 ps) (rp:v* u (* 50.0 tol))) (caddr ps)) (rp:p3 ps (caddr ps)))
            xs (rp:inters ln mobj acExtendNone)
            bd 1e99)
      (vla-Delete ln)
      (foreach x xs (if (< (setq d (distance (rp:p2 x) (rp:p2 ps))) bd) (setq bd d best x)))
      (if best
        (progn
          (if (< (abs (vla-GetBulge o 0)) 1e-9)
            (vla-put-Coordinate o 0 (rp:pt2var best))
            (vla-AddVertex o 0 (rp:pt2var best)))
          T)))))

(defun rp:rebuild-one (e snap / res)
  (setq *rp:presetcl* e
        res (rp:with-settings (append snap '(("rmode" . "0") ("report" . "0") ("xsec" . "0") ("keep" . "0"))) 'rp:run)
        *rp:presetcl* nil)
  (if (vl-catch-all-error-p res)
    (progn (princ (strcat "\n** Rebuild failed: " (vl-catch-all-error-message res) " - type U to undo.")) nil)
    T))

(defun rp:replay-w () (rp:widen-run *rp:re*))
(defun rp:replay-t () (rp:taper-run *rp:re*))
(defun rp:replay-j () (rp:junction-run *rp:re*))
(defun rp:replay-r () (rp:rbt-run *rp:re* *rp:rdj* *rp:rbrs*))

;; Replay the operation log ops on road e (and on the branches it builds)
(defun rp:replay (e ops / old b brs data fac st0 h hd)
  (setq old *rp:replay* *rp:replay* T)
  (foreach op ops
    (setq *rp:re* e *rp:mk0* (entlast))
    (cond
      ((= (car op) "W") (rp:with-settings (cadr op) 'rp:replay-w))
      ((= (car op) "T") (rp:with-settings (cadr op) 'rp:replay-t))
      ((= (car op) "J")
       (setq h (car (caddr op)))
       (if (and h (setq b (handent h)) (entget b))
         (progn
           (setq *rp:presetcl* b)
           (rp:with-settings (cadr op) 'rp:replay-j)
           (setq *rp:presetcl* nil)
           (if (vlax-ldata-get (vlax-ename->vla-object b) "ROADPRO_OPSV") (rp:replay b (cdr (assoc h *rp:gops*)))))))
      ((= (car op) "R")
       (setq data (rp:xget e) fac (atof (rp:xv "FAC" data)))
       (if (<= fac 0.0) (setq fac 1.0))
       (setq st0 (atof (rp:xv "CHST" data)) brs nil)
       (foreach x (cadr (caddr op))
         (if (and (setq b (handent (car x))) (entget b))
           (progn
             ;; v3.6 : the side road starts where the corner fillets ended - put back its
             ;; first piece so it starts at the roundabout again
             (if (and (setq hd (vlax-ldata-get (vlax-ename->vla-object b) "RPJHEAD"))
                      (< (distance (rp:p2 (last (car hd))) (rp:p2 (vlax-curve-getStartPoint b))) (* 0.01 fac)))
               (rp:pl-prepend (vlax-ename->vla-object b) hd))
             (setq brs (append brs (list (list b (cadr x) (caddr x))))))))
       (setq *rp:rbrs* brs *rp:rdj* (* fac (- (car (caddr op)) st0)))
       (rp:with-settings (cadr op) 'rp:replay-r)
       (foreach x (cadr (caddr op))
         (if (and (setq b (handent (car x))) (entget b) (vlax-ldata-get (vlax-ename->vla-object b) "ROADPRO_OPSV"))
           (rp:replay b (cdr (assoc (car x) *rp:gops*))))))))
  (setq *rp:replay* old)
  (princ))

;; v3.6 : keep every curve tangent to its straights after a centre line edit.
;; A grip edit of a curve (its radius) or of a tangent point leaves the arc kinked
;; against the straights : the arc is fitted again with its present radius between
;; the two straights (as RDER does). Returns T when the line was changed.
(defun rp:cl-tangentize (obj / pd pts bul n i a0 a1 sw th1 th2 r res chg cl tol)
  (setq pd (rp:pldata obj) pts (car pd) bul (cadr pd) n (length pts) tol (/ pi 1800.0)
        cl (vlax-curve-isClosed obj) i (- n 2))
  (while (>= i 1)
    (if (and (> (abs (nth i bul)) 1e-9) (< (abs (nth (1- i) bul)) 1e-9)
             (< (+ i 2) n) (< (abs (nth (1+ i) bul)) 1e-9))
      (progn
        (setq sw  (* 4.0 (atan (nth i bul)))
              a0  (angle (nth i pts) (nth (1+ i) pts))
              th1 (abs (rp:angdiff (angle (nth (1- i) pts) (nth i pts)) (- a0 (* 0.5 sw))))
              th2 (abs (rp:angdiff (+ a0 (* 0.5 sw)) (angle (nth (1+ i) pts) (nth (+ i 2) pts)))))
        (if (or (> th1 tol) (> th2 tol))
          (progn
            (setq r   (/ (distance (nth i pts) (nth (1+ i) pts)) (* 2.0 (abs (sin (* 0.5 sw)))))
                  res (rp:fit-radius pts bul cl i r))
            (if (= (type res) 'LIST)
              (setq pts (car res) bul (cadr res) chg T n (length pts)))))))
    (setq i (1- i)))
  (if chg (rp:pl-set obj pts bul))
  chg)

;; Rebuild road e from its centre line as it is now, with snapshot snap
;; (nil = the road's stored settings). Returns T when rebuilt.
(defun rp:rebuild (e snap / obj data nw nt nj go lst res grp)
  (setq obj  (vlax-ename->vla-object e)
        data (rp:xget e))
  (if (null snap) (setq snap (vlax-ldata-get obj "ROADPRO_SET")))
  (if (null snap) (setq snap (rp:snapshot-from-xdata data)))
  (setq nw (length (vlax-ldata-get obj "ROADPRO_WIDEN"))
        nt (length (vlax-ldata-get obj "ROADPRO_TAPERS"))
        nj (+ (length (vlax-ldata-get obj "ROADPRO_JUNC")) (length (vlax-ldata-get obj "ROADPRO_RBT")))
        go T)
  (cond
    ;; v3.5 road : rebuild the group and replay everything
    ((vlax-ldata-get obj "ROADPRO_OPSV")
     (setq grp (rp:group e)
           *rp:gops* (mapcar '(lambda (x) (cons (vla-get-Handle (vlax-ename->vla-object x))
                                                 (vlax-ldata-get (vlax-ename->vla-object x) "ROADPRO_OPS")))
                             grp))
     (foreach x grp (setq lst (append lst (rp:road-objects x))))
     (foreach x lst (if (entget x) (entdel x)))
     (foreach x grp (rp:ldata-clear x (eq x e)))
     (if (setq res (rp:rebuild-one e snap))
       (progn
         (rp:replay e (cdr (assoc (vla-get-Handle obj) *rp:gops*)))
         (princ (strcat "\n  Road rebuilt (" (itoa (length lst)) " old objects replaced"
                        (if (> (+ nw nt nj) 0) ", widenings / tapers / junctions / roundabouts replayed" "")
                        "). Report tables and cross sections drawn earlier are out of date - run RDR / RDX again."))))
     (setq *rp:gops* nil)
     res)
    ;; road built before v3.5 with widenings / tapers / junctions : as in v3.4
    (T
     (if (> (+ nw nt nj) 0)
       (if *rp:live-run*
         (progn
           (princ "\n  Live update skipped : this road was built before v3.5 and has widenings / tapers / junctions - run RDB.")
           (setq go nil))
         (progn
           (princ (strcat "\n  This road was built before v3.5 and has " (itoa nw) " lane widening(s), " (itoa nt)
                          " taper(s) and " (itoa nj) " junction(s)."
                          "\n  The rebuild draws the road again without them - apply them again afterwards with RDW / RDT / RDJ"
                          "\n  (from then on, v3.5 keeps them through every rebuild)."))
           (initget "Yes No")
           (setq go (= (getkword "\nRebuild the road now? [Yes/No] <No>: ") "Yes")))))
     (if go
       (progn
         (setq lst (rp:road-objects e))
         (foreach x lst (if (entget x) (entdel x)))
         (rp:ldata-clear e T)
         (if (setq res (rp:rebuild-one e snap))
           (princ (strcat "\n  Road rebuilt (" (itoa (length lst)) " old objects replaced)."
                          " Report tables and cross sections drawn earlier are out of date - run RDR / RDX again.")))
         res)))))

;;---------------------------------------------------------------------------
;;  Live update (reactors)
;;---------------------------------------------------------------------------
(setq *rp:busy* nil *rp:live-q* nil)

(defun rp:live-on () (/= (rp:val "live") "0"))

(defun rp:live-attach (e / o)
  (if (and e (entget e))
    (progn
      (setq o (vlax-ename->vla-object e))
      (cond
        ((null *rp:live-r*)
         (setq *rp:live-r* (vlr-object-reactor (list o) "RoadProLive" '((:vlr-modified . rp:live-mod)))))
        ((not (member o (vlr-owners *rp:live-r*)))
         (vlr-owner-add *rp:live-r* o)))
      (if (null *rp:live-c*)
        (setq *rp:live-c* (vlr-command-reactor "RoadProLive"
                                               '((:vlr-commandEnded . rp:live-end)
                                                 (:vlr-commandCancelled . rp:live-cancel)
                                                 (:vlr-commandFailed . rp:live-cancel))))))))

;; every RoadPro centre line of the drawing (at load time)
(defun rp:live-init (/ ss i)
  (if (setq ss (ssget "_X" '((0 . "LWPOLYLINE") (-3 ("ROADPRO")))))
    (progn
      (setq i 0)
      (repeat (sslength ss) (rp:live-attach (ssname ss i)) (setq i (1+ i))))))

(defun rp:live-mod (o r p)
  (if (and (not *rp:busy*) (not (member o *rp:live-q*)))
    (setq *rp:live-q* (cons o *rp:live-q*))))

(defun rp:live-cancel (r p) (setq *rp:live-q* nil))

(defun rp:live-end (r p / c)
  (setq c (strcase (car p)))
  (cond
    ((wcmatch c "U,UNDO,REDO,MREDO,OOPS") (setq *rp:live-q* nil))
    ((not (rp:live-on)) (setq *rp:live-q* nil))
    ((and *rp:live-q* (not *rp:busy*))
     (vla-SendCommand (vla-get-ActiveDocument (vlax-get-acad-object)) "ROADPROLIVEUPDATE "))))

;; one edited centre line : returns the roads that were handled
(defun rp:live-process (e / obj geo pd top tr grp)
  (setq obj (vlax-ename->vla-object e)
        geo (vlax-ldata-get obj "ROADPRO_GEOM"))
  (if (rp:cl-tangentize obj)
    (princ "\n  RoadPro live update : curve kept tangent to the straights (radius as edited)."))
  (setq pd  (rp:pldata obj))
  (cond
    ((null (vlax-ldata-get obj "ROADPRO_ALL"))
     (princ "\n  RoadPro live update : road built before v3.4 - run RDB on it once.")
     (list e))
    ((and geo (rp:geom-same geo pd)) (list e))          ; only properties changed
    (T
     (setq top (rp:group-top e))
     (if (and (eq top e) geo (setq tr (rp:rigid (car geo) (cadr geo) (car pd) (cadr pd))))
       (rp:move-branches e tr))
     (setq grp (rp:group top))
     (princ (strcat "\n  RoadPro live update : rebuilding " (rp:xv "NAME" (rp:xget top))
                    (if (cdr grp) (strcat " and " (itoa (1- (length grp))) " joined road(s)") "") " ..."))
     (rp:rebuild top nil)
     grp)))

;; run by the reactor when a command that edited a road centre line ends
(defun c:ROADPROLIVEUPDATE (/ q done e)
  (setq q (reverse *rp:live-q*) *rp:live-q* nil)
  (if (and q (rp:live-on))
    (progn
      (rp:start) (rp:space) (rp:world) (rp:linetypes) (rp:layers)
      (setq *rp:live-run* T)
      (foreach o q
        (if (and (not (vlax-erased-p o))
                 (setq e (vl-catch-all-apply 'vlax-vla-object->ename (list o)))
                 (not (vl-catch-all-error-p e))
                 (rp:xget e)
                 (not (member e done)))
          (setq done (append done (rp:live-process e)))))
      (setq *rp:live-run* nil)
      (rp:finish)))
  (princ))

(defun c:ROADLIVE (/ k)
  (initget "On Off")
  (setq k (getkword (strcat "\nLive update when a road centre line is edited [On/Off] <" (if (rp:live-on) "On" "Off") ">: ")))
  (if k (rp:set "live" (if (= k "On") "1" "0")))
  (vl-catch-all-apply 'rp:live-init nil)
  (princ (if (rp:live-on)
           "\n  RoadPro LIVE update is ON : grip-edit / MOVE / ROTATE / STRETCH / PEDIT a road centre line and the road, corridor, markings, junctions and roundabouts follow."
           "\n  RoadPro LIVE update is OFF : run RDB after editing a centre line."))
  (princ))

(defun c:RDLIVE () (c:ROADLIVE))

;;============================================================================
;;  v3.5  PERMANENT ADD-IN (AutoCAD / Civil 3D / Map 3D 2013 and newer, all
;;  profiles). Load RoadPro.lsp ONCE with APPLOAD : it copies itself to
;;  %APPDATA%\RoadPro, adds that folder to the support and trusted paths and
;;  to the APPLOAD Startup Suite, so it loads in every drawing from then on.
;;  ROADPROINSTALL (RDINSTALL) repeats it, ROADPROUNINSTALL (RDUNINSTALL) undoes it.
;;============================================================================
(defun rp:prodkey () (if vlax-user-product-key (vlax-user-product-key) (vlax-product-key)))

(defun rp:startup-key ()
  (strcat "HKEY_CURRENT_USER\\" (rp:prodkey) "\\Profiles\\" (getvar "CPROFILE") "\\Dialogs\\Appload\\Startup"))

;; install mark per AutoCAD profile (each profile has its own Startup Suite)
(defun rp:instkey () (strcat "RoadPro_inst_" (getvar "CPROFILE")))

(defun rp:inst-dir () (strcat (getenv "APPDATA") "\\RoadPro"))

;; version written in a RoadPro.lsp file
(defun rp:file-ver (fn / f l v p q)
  (if (and fn (setq f (open fn "r")))
    (progn
      (while (and (not v) (setq l (read-line f)))
        (if (and (setq p (vl-string-search "(setq *rp:ver* \"" l))
                 (setq q (vl-string-search "\"" l (+ p 16))))
          (setq v (substr l (+ p 17) (- q p 16)))))
      (close f)))
  v)

;; ask = T : may ask for the file with a file dialog. Returns T when installed
(defun rp:install (ask / dir dir0 src dst f key n i v found files sp tp)
  (setq dir0 (rp:inst-dir) dir (strcat dir0 "\\"))
  (vl-mkdir dir0)
  (setq src (findfile "RoadPro.lsp"))
  (if (and src (/= (rp:file-ver src) *rp:ver*)) (setq src nil))
  (if (and (null src) ask)
    (progn
      (alert (strcat "RoadPro v" *rp:ver* " - one-time setup\n\n"
                     "Select the RoadPro.lsp file you have just loaded.\n"
                     "It is copied to " dir0 " and loads in every drawing from now on."))
      (setq src (getfiled "RoadPro - select RoadPro.lsp (one-time setup)"
                          (strcat (getenv "USERPROFILE") "\\Downloads\\") "lsp" 8))
      (if (and src (/= (rp:file-ver src) *rp:ver*))
        (progn
          (alert (strcat "That file is RoadPro v" (if (rp:file-ver src) (rp:file-ver src) "?")
                         ", not v" *rp:ver* ".\nNothing installed."))
          (setq src nil)))))
  (if src
    (progn
      (setq dst (strcat dir "RoadPro.lsp"))
      (if (/= (strcase src) (strcase dst))
        (progn
          (if (findfile dst) (vl-file-delete dst))
          (vl-file-copy src dst)))
      (if (setq f (open (strcat dir "RP_PAVER.pat") "w"))
        (progn (foreach l *rp:paver-pat* (write-line l f)) (close f)))
      ;; support and trusted paths
      (setq files (vla-get-Files (vla-get-Preferences (vlax-get-acad-object)))
            sp    (vla-get-SupportPath files))
      (if (not (vl-string-search (strcase dir0) (strcase sp)))
        (vl-catch-all-apply 'vla-put-SupportPath (list files (strcat dir0 ";" sp))))
      (if (setq tp (getvar "TRUSTEDPATHS"))
        (if (not (vl-string-search (strcase dir0) (strcase tp)))
          (vl-catch-all-apply 'setvar (list "TRUSTEDPATHS" (if (= tp "") dir0 (strcat tp ";" dir0))))))
      ;; APPLOAD Startup Suite of the current profile
      (setq key (rp:startup-key)
            n   (atoi (if (setq v (vl-registry-read key "NumStartup")) v "0"))
            i   1)
      (while (<= i n)
        (setq v (vl-registry-read key (strcat (itoa i) "Startup")))
        (if (and v (wcmatch (strcase v) "*\\ROADPRO.LSP"))
          (progn (setq found T) (vl-registry-write key (strcat (itoa i) "Startup") dst)))
        (setq i (1+ i)))
      (if (not found)
        (progn
          (vl-registry-write key (strcat (itoa (1+ n)) "Startup") dst)
          (vl-registry-write key "NumStartup" (itoa (1+ n)))))
      (setenv (rp:instkey) *rp:ver*)
      (setenv "RoadPro_instpath" dst)
      (princ (strcat "\n  RoadPro v" *rp:ver* " is installed permanently (" dst ")."
                     "\n  It loads automatically in every drawing - in AutoCAD and in Civil 3D."))
      T)
    (progn
      (if ask (princ "\n  RoadPro was not installed - type RDINSTALL to try again."))
      nil)))

(defun rp:uninstall (/ key n i v keep k dir0 files sp)
  (setq key (rp:startup-key)
        n   (atoi (if (setq v (vl-registry-read key "NumStartup")) v "0"))
        i   1)
  (while (<= i n)
    (setq v (vl-registry-read key (strcat (itoa i) "Startup")))
    (if (and v (not (wcmatch (strcase v) "*\\ROADPRO.LSP"))) (setq keep (append keep (list v))))
    (vl-registry-delete key (strcat (itoa i) "Startup"))
    (setq i (1+ i)))
  (setq k 1)
  (foreach v keep (vl-registry-write key (strcat (itoa k) "Startup") v) (setq k (1+ k)))
  (vl-registry-write key "NumStartup" (itoa (length keep)))
  (setq dir0  (rp:inst-dir)
        files (vla-get-Files (vla-get-Preferences (vlax-get-acad-object)))
        sp    (vla-get-SupportPath files))
  (if (vl-string-search (strcase (strcat dir0 ";")) (strcase sp))
    (vl-catch-all-apply 'vla-put-SupportPath
                        (list files (vl-string-subst "" (strcat dir0 ";") sp))))
  (setenv (rp:instkey) "")
  (setenv "RoadPro_instskip" *rp:ver*)
  (princ (strcat "\n  RoadPro removed from the Startup Suite. The files stay in " dir0 " (delete them by hand if you wish)."))
  (princ))

;; RoadPro installed as an Autodesk add-in bundle (ApplicationPlugins) ?
(defun rp:bundle-p (/ r)
  (foreach d (list (getenv "APPDATA") (getenv "PROGRAMDATA") (getenv "ProgramFiles"))
    (if (and d (not r))
      (setq r (findfile (strcat d "\\Autodesk\\ApplicationPlugins\\RoadPro.bundle\\PackageContents.xml")))))
  r)

;; remove an old RoadPro entry from the Startup Suite (the bundle loads it now)
(defun rp:startup-clean (/ key n i v keep k found)
  (setq key (rp:startup-key)
        n   (atoi (if (setq v (vl-registry-read key "NumStartup")) v "0"))
        i   1)
  (while (<= i n)
    (setq v (vl-registry-read key (strcat (itoa i) "Startup")))
    (if (and v (wcmatch (strcase v) "*\\ROADPRO.LSP")) (setq found T) (if v (setq keep (append keep (list v)))))
    (setq i (1+ i)))
  (if found
    (progn
      (setq i 1)
      (repeat n (vl-registry-delete key (strcat (itoa i) "Startup")) (setq i (1+ i)))
      (setq k 1)
      (foreach v keep (vl-registry-write key (strcat (itoa k) "Startup") v) (setq k (1+ k)))
      (vl-registry-write key "NumStartup" (itoa (length keep)))
      (princ "\n  RoadPro : the old Startup Suite entry was removed - the add-in bundle loads RoadPro now.")))
  found)

;; at load : install once per version. Done when the current command (APPLOAD)
;; ends, so the APPLOAD dialog cannot overwrite the Startup Suite entry.
(defun rp:autoinstall ()
  (cond
    ((rp:bundle-p) (rp:startup-clean) nil)
    ((= (getenv (rp:instkey)) *rp:ver*) nil)
    ((= (getenv "RoadPro_instskip") *rp:ver*) nil)
    (T
     (setq *rp:inst-pending* T)
     (if (null *rp:inst-r*)
       (setq *rp:inst-r* (vlr-command-reactor "RoadProInstall" '((:vlr-commandEnded . rp:inst-end))))))))

(defun rp:inst-end (r p)
  (if *rp:inst-pending*
    (progn
      (setq *rp:inst-pending* nil)
      (vla-SendCommand (vla-get-ActiveDocument (vlax-get-acad-object)) "ROADPROINSTALL "))))

(defun c:ROADPROINSTALL ()
  (cond
    ((rp:bundle-p)
     (princ (strcat "\n  RoadPro is installed as an add-in bundle : " (vl-filename-directory (rp:bundle-p))
                    "\n  It loads by itself in every drawing (AutoCAD and Civil 3D). Nothing else to do.")))
    ((not (rp:install T)) (setenv "RoadPro_instskip" *rp:ver*)))
  (princ))
(defun c:RDINSTALL () (c:ROADPROINSTALL))

(defun c:ROADPROUNINSTALL ()
  (initget "Yes No")
  (if (= (getkword "\nRemove RoadPro from the Startup Suite (it will not load automatically any more)? [Yes/No] <No>: ") "Yes")
    (rp:uninstall))
  (princ))
(defun c:RDUNINSTALL () (c:ROADPROUNINSTALL))

;;---------------------------------------------------------------------------
;;  RoadPro menu in the menu bar (MENUBAR = 1 shows it) and the help list
;;---------------------------------------------------------------------------
(setq *rp:cmds*
 '(("RDP"     "ROADPRO"         "Build a complete road from a centre line")
   ("RDR"     "ROADREPORT"      "Report tables + Excel (CSV) file")
   ("RDRAD"   "ROADRADIUS"      "Radius, TC / CT and curve data on plan")
   ("RDSEC"   "ROADSECTIONS"    "Straight sections S1, S2 ... on plan")
   ("RDX"     "ROADXSEC"        "Cross sections to corridor limit, pro dimensions + level table")
   ("RDW"     "ROADWIDEN"       "Lane widening")
   ("RDT"     "ROADTAPER"       "Road taper (wider / narrower)")
   ("RDJ"     "ROADJUNCTION"    "Junction : kerb returns, Saudi standard, or roundabout")
   ("RDRB"    "ROADROUNDABOUT"  "Roundabout 2 / 3 / 4-way, automatic legs, full marking (FHWA)")
   ("RDM"     "ROADMARK"        "Road markings")
   ("RDL"     "ROADLINE"        "Single line of barricades / cones / kerb")
   ("RDC"     "ROADCORRIDOR"    "Lanes, median, sidewalks, drains, utilities")
   ("RDPV"    "ROADPAVEMENT"    "Pavement : asphalt or concrete (earthwork, stone base, steel)")
   ("RDU"     "ROADUPDATE"      "Regenerate corridor + markings")
   ("RDER"    "ROADEDITRADIUS"  "Edit a curve radius, rebuild (barricades follow)")
   ("RDB"     "ROADREBUILD"     "Rebuild from the edited centre line (keeps widenings, junctions ...)")
   ("RDLIVE"  "ROADLIVE"        "Live update on / off")
   ("RDLX"    "ROADLANDXML"     "LandXML export (Civil 3D)")
   ("RDLXI"   "ROADLANDXMLIN"   "LandXML import")
   ("RDINSTALL" "ROADPROINSTALL" "Install permanently (Startup Suite)")
   ("RDUNINSTALL" "ROADPROUNINSTALL" "Remove from the Startup Suite")
   ("RDHELP"  "ROADHELP"        "This list")))

(defun rp:menu (/ acad mgs mg menus pm k r)
  (setq acad (vlax-get-acad-object)
        mgs  (vla-get-MenuGroups acad))
  (if (> (vla-get-Count mgs) 0)
    (progn
      (setq mg    (vla-Item mgs 0)
            menus (vla-get-Menus mg)
            r     (vl-catch-all-apply 'vla-Item (list menus "Road&Pro")))
      (if (vl-catch-all-error-p r)
        (progn
          (setq pm (vla-Add menus "Road&Pro") k 0)
          (foreach c *rp:cmds*
            (vla-AddMenuItem pm k (strcat (caddr c) "   (" (car c) ")") (strcat (chr 3) (chr 3) "_" (car c) " "))
            (setq k (1+ k))
            (if (member (car c) '("RDX" "RDRB" "RDPV" "RDLIVE" "RDLXI"))
              (progn (vla-AddSeparator pm k) (setq k (1+ k))))))
        (setq pm r))
      (if (= (vla-get-OnMenuBar pm) :vlax-false)
        (vla-InsertInMenuBar pm (vla-get-Count (vla-get-MenuBar acad)))))))

(defun c:ROADHELP ()
  (princ (strcat "\n================ ROAD PRO v" *rp:ver* " - COMMANDS ================"))
  (foreach c *rp:cmds*
    (princ (strcat "\n  " (rp:pad (car c) 12) (rp:pad (cadr c) 18) (caddr c))))
  (princ (strcat "\n  Live update : " (if (rp:live-on) "ON" "OFF")
                 "   |   Installed : " (cond ((rp:bundle-p) "add-in bundle (ApplicationPlugins)") ((= (getenv (rp:instkey)) *rp:ver*) (getenv "RoadPro_instpath")) (T "no - run Install_RoadPro.bat or type RDINSTALL"))))
  (princ "\n  Developed by https://www.exceltokml.com/")
  (textscr)
  (princ))
(defun c:RDHELP () (c:ROADHELP))

;;----------------------------------------------------------------------------
;;  Commands
;;----------------------------------------------------------------------------
(defun c:ROADPRO (/ res)
  (rp:start)
  (setq res (rp:dialog))
  (if (= res 'fail)
    (progn
      (princ "\nDialog not available - using command line.")
      (rp:cmdline)
      (setq res 'ok)))
  (if (= res 'ok) (rp:run) (princ "\nRoad Pro cancelled."))
  (rp:finish))

(defun c:RDP () (c:ROADPRO))

(defun c:ROADREPORT (/ sel)
  (rp:start)
  (rp:space)
  (rp:world)
  (rp:linetypes)
  (rp:layers)
  (while (and (setq sel (entsel "\nSelect the road centre line (layer ROAD-CL): "))
              (not (rp:xget (car sel))))
    (princ "\n  No RoadPro data on this object - select the centre line of a RoadPro road."))
  (if sel (rp:report-make (car sel) T))
  (rp:finish))

(defun c:RDR () (c:ROADREPORT))

;; Add radius / TC / CT / curve data labels to an existing RoadPro road
(defun c:ROADRADIUS (/ sel e data fac obj hw n)
  (rp:start)
  (rp:space)
  (rp:world)
  (rp:linetypes)
  (rp:layers)
  (setq *rp:hatches* nil)
  (while (and (setq sel (entsel "\nSelect the road centre line (layer ROAD-CL): "))
              (not (rp:xget (car sel))))
    (princ "\n  No RoadPro data on this object - select the centre line of a RoadPro road."))
  (if sel
    (progn
      (setq e    (car sel)
            data (rp:xget e)
            fac  (atof (rp:xv "FAC" data)))
      (if (<= fac 0.0) (setq fac 1.0))
      (setq obj      (vlax-ename->vla-object e)
            *rp:cset* (vlax-ldata-get obj "ROADPRO_SET")
            *rp:cinx* (if *rp:cset* (list (rp:corr-extra 1.0 fac (* fac (atof (rp:xv "BGAP" data))) (* fac (atof (rp:xv "BWID" data))))
                                          (rp:corr-extra -1.0 fac (* fac (atof (rp:xv "BGAP" data))) (* fac (atof (rp:xv "BWID" data))))))
            hw       (* 0.5 fac (atof (rp:xv "W" data)))
            *rp:len* (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
            n        (rp:curve-labels obj (rp:curves obj) hw fac (* fac (rp:num "txth"))
                                      (atof (rp:xv "CHST" data)) (vla-get-Elevation obj)
                                      (/= (rp:xv "BL" data) "0,0") (/= (rp:xv "BR" data) "0,0")
                                      (/= (atoi (rp:xv "NCHM" data)) 0)
                                      (* fac (atof (rp:xv "BGAP" data)))
                                      (* fac (atof (rp:xv "BWID" data)))
                                      (= (rp:xv "RREF" data) "1")))
      (rp:track e *rp:mk0*)
      (princ (strcat "\n  Radius labels added to " (itoa n) " curve(s) on layer ROAD-CURVE."))))
  (rp:finish))

(defun c:RDRAD () (c:ROADRADIUS))

;; Add straight-section labels to an existing RoadPro road
(defun c:ROADSECTIONS (/ sel e data fac obj hw n)
  (rp:start)
  (rp:space)
  (rp:world)
  (rp:linetypes)
  (rp:layers)
  (while (and (setq sel (entsel "\nSelect the road centre line (layer ROAD-CL): "))
              (not (rp:xget (car sel))))
    (princ "\n  No RoadPro data on this object - select the centre line of a RoadPro road."))
  (if sel
    (progn
      (setq e    (car sel)
            data (rp:xget e)
            fac  (atof (rp:xv "FAC" data)))
      (if (<= fac 0.0) (setq fac 1.0))
      (setq obj      (vlax-ename->vla-object e)
            hw       (* 0.5 fac (atof (rp:xv "W" data)))
            *rp:len* (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj))
            n        (rp:straight-labels
                       obj (rp:straights obj) hw fac (* fac (rp:num "txth"))
                       (atof (rp:xv "CHST" data)) (vla-get-Elevation obj)
                       (+ hw
                          (if (/= (rp:xv "BR" data) "0,0")
                            (* fac (+ (atof (rp:xv "BGAP" data)) (atof (rp:xv "BWID" data))))
                            0.0)
                          (* 0.5 fac) (* 0.6 fac) (* 1.5 fac (rp:num "signsz")))))
      (rp:track e *rp:mk0*)
      (princ (strcat "\n  " (itoa n) " straight section(s) labelled on layer ROAD-SECTION."))))
  (rp:finish))

(defun c:RDSEC () (c:ROADSECTIONS))

;; Cross section drawings of a RoadPro road
(defun c:ROADXSEC (/ sel res)
  (rp:start)
  (rp:space)
  (rp:world)
  (rp:linetypes)
  (rp:layers)
  (while (and (setq sel (entsel "\nSelect the road centre line (layer ROAD-CL): "))
              (not (rp:xget (car sel))))
    (princ "\n  No RoadPro data on this object - select the centre line of a RoadPro road."))
  (if sel
    (progn
      (setq res (rp:xdialog))
      (if (= res 'fail) (princ "\nDialog not available - using saved cross-section settings."))
      (if (/= res 'cancel)
        (rp:xsec-run (car sel) (rp:val "xmode"))
        (princ "\nCross section cancelled."))))
  (rp:finish))

(defun c:RDX () (c:ROADXSEC))

;; Lane widening on a RoadPro road
(defun c:ROADWIDEN (/ sel data fac len res)
  (rp:start)
  (rp:space)
  (rp:world)
  (rp:linetypes)
  (rp:layers)
  (while (and (setq sel (entsel "\nSelect the road centre line (layer ROAD-CL): "))
              (not (rp:xget (car sel))))
    (princ "\n  No RoadPro data on this object - select the centre line of a RoadPro road."))
  (if sel
    (progn
      (setq data (rp:xget (car sel))
            fac  (atof (rp:xv "FAC" data)))
      (if (<= fac 0.0) (setq fac 1.0))
      (setq len (vlax-curve-getDistAtParam (car sel) (vlax-curve-getEndParam (car sel))))
      (setq res (rp:wdialog (strcat "Road " (rp:xv "NAME" data) " :  CH "
                                    (rp:chfmt (atof (rp:xv "CHST" data))) "  to  "
                                    (rp:chfmt (+ (atof (rp:xv "CHST" data)) (/ len fac)))
                                    "   |   width " (rp:xv "W" data) " m")))
      (if (= res 'fail) (princ "\nDialog not available - using saved widening settings."))
      (if (/= res 'cancel)
        (rp:widen-run (car sel))
        (princ "\nLane widening cancelled."))))
  (rp:finish))

(defun c:RDW () (c:ROADWIDEN))

;; Road taper anywhere on a RoadPro road
(defun c:ROADTAPER (/ sel data fac len res)
  (rp:start)
  (rp:space)
  (rp:world)
  (rp:linetypes)
  (rp:layers)
  (while (and (setq sel (entsel "\nSelect the road centre line (layer ROAD-CL): "))
              (not (rp:xget (car sel))))
    (princ "\n  No RoadPro data on this object - select the centre line of a RoadPro road."))
  (if sel
    (progn
      (setq data (rp:xget (car sel))
            fac  (atof (rp:xv "FAC" data)))
      (if (<= fac 0.0) (setq fac 1.0))
      (setq len (vlax-curve-getDistAtParam (car sel) (vlax-curve-getEndParam (car sel))))
      (setq res (rp:tdialog (strcat "Road " (rp:xv "NAME" data) " :  CH "
                                    (rp:chfmt (atof (rp:xv "CHST" data))) "  to  "
                                    (rp:chfmt (+ (atof (rp:xv "CHST" data)) (/ len fac)))
                                    "   |   design width " (rp:xv "W" data) " m")))
      (if (= res 'fail) (princ "\nDialog not available - using saved taper settings."))
      (if (/= res 'cancel)
        (rp:taper-run (car sel))
        (princ "\nRoad taper cancelled."))))
  (rp:finish))

(defun c:RDT () (c:ROADTAPER))

;; Join a new road to an existing RoadPro road
(defun c:ROADJUNCTION (/ sel data fac len res)
  (rp:start)
  (rp:space)
  (rp:world)
  (rp:linetypes)
  (rp:layers)
  (setq *rp:presetcl* nil)
  (while (and (setq sel (entsel "\nSelect the MAIN road centre line (layer ROAD-CL): "))
              (not (rp:xget (car sel))))
    (princ "\n  No RoadPro data on this object - select the centre line of a RoadPro road."))
  (if sel
    (progn
      (setq data (rp:xget (car sel))
            fac  (atof (rp:xv "FAC" data)))
      (if (<= fac 0.0) (setq fac 1.0))
      (setq len (vlax-curve-getDistAtParam (car sel) (vlax-curve-getEndParam (car sel)))
            *rp:jspd* (if (> (atof (rp:xv "SPEED" data)) 0.0) (atof (rp:xv "SPEED" data)) 50.0))
      (setq res (rp:jdialog (strcat "Main road " (rp:xv "NAME" data) " :  CH "
                                    (rp:chfmt (atof (rp:xv "CHST" data))) "  to  "
                                    (rp:chfmt (+ (atof (rp:xv "CHST" data)) (/ len fac)))
                                    "   |   width " (rp:xv "W" data) " m   |   " (rp:xv "SPEED" data) " km/h")))
      (if (= res 'fail) (princ "\nDialog not available - using saved junction settings."))
      (if (/= res 'cancel)
        (rp:junction-run (car sel))
        (princ "\nRoad junction cancelled."))))
  (setq *rp:presetcl* nil)
  (rp:finish))

(defun c:RDJ () (c:ROADJUNCTION))

;; Road markings on any RoadPro road (draw again = refresh, or remove)
(defun c:ROADMARK (/ sel opt obj en)
  (rp:start)
  (rp:space)
  (rp:world)
  (rp:linetypes)
  (rp:layers)
  (while (and (setq sel (entsel "\nSelect the road centre line (layer ROAD-CL): "))
              (not (rp:xget (car sel))))
    (princ "\n  No RoadPro data on this object - select the centre line of a RoadPro road."))
  (if sel
    (progn
      (initget "Draw Remove")
      (setq opt (getkword "\nRoad markings [Draw/Remove] <Draw>: "))
      (if (= opt "Remove")
        (progn
          (setq obj (vlax-ename->vla-object (car sel)))
          (foreach hd (vlax-ldata-get obj "ROADPRO_MKMAN")
            (if (and (setq en (handent hd)) (entget en)) (entdel en)))
          (vlax-ldata-delete obj "ROADPRO_MKMAN")
          (vlax-ldata-delete obj "ROADPRO_MKQTY")
          (princ "\n  Road markings removed."))
        (rp:mark-run (car sel)))))
  (rp:finish))

(defun c:RDM () (c:ROADMARK))

(defun c:ROADPRORESET ()
  (foreach p *rp:defaults* (rp:set (car p) (cdr p)))
  (princ "\nRoad Pro settings restored to defaults (width 7.30 m, radius 10 m).")
  (princ))

(setq *rp:busy* nil)
(vl-catch-all-apply 'rp:live-init nil)
(vl-catch-all-apply 'rp:menu nil)
(vl-catch-all-apply 'rp:autoinstall nil)
(princ (strcat "\nRoad Pro v" *rp:ver* " loaded  (AutoCAD / Civil 3D).  RDP = build road   |   RDJ = junction / roundabout   |   RDRB = roundabout   |   RDPV = pavement (asphalt / concrete)   |   RDC = corridor   |   RDR = report   |   RDX = cross sections   |   RDLIVE = live update "
               (if (rp:live-on) "ON" "OFF") "   |   RDHELP = all commands"))
(princ "\nDeveloped by https://www.exceltokml.com/")
(princ)
