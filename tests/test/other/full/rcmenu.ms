-------------------------------------------------------------------------------
--
--   RCMENU.MS
--   This script adds new items to MAX's right click menu
--   By Ravi Karra [Kinetix] 			ravi.karra@ktx.com
--	 Commands added by Frank DeLise
--	 Make sure you have MXSAgni.dlx file in MAX Plugins folder
--	 Please refer to MXSAgni.doc for information on the functions in MXSAgni.dlx
--	 Build 5-03-98 .1
-------------------------------------------------------------------------------

-- Array of all the menu items that are added
menu_items = #()

--This function gets called when a menu item is selected
fn fnSelected item =
(
	case item of
	(
	"Edit CV's":(
	
	If $.modifiers[1] == undefined then
		(
		Max modify mode
		subobjectlevel = 1
		)
		else
		(
		if Querybox "Collapse" beep:yes then (
			
			local obj = $
			Converttomesh $
			select obj
			Max modify mode
			subobjectlevel = 1
			)
		)	
	)
	

	
	"Edit Vertices":(
	
	If $.modifiers[1] == undefined then
		(
		Max modify mode
		subobjectlevel = 1
		)
		else
		(
		if Querybox "Collapse" beep:yes then (
			
			local obj = $
			Converttomesh $
			select obj
			Max modify mode
			subobjectlevel = 1
			)
		)	
	)
	
	"Edit Faces":(
		If $.modifiers[1] == undefined then
		(
		Max modify mode
		subobjectlevel = 2
		)
		else
		(
		if Querybox "Collapse" beep:yes then (
			
			local obj = $
			Converttomesh $
			select obj
			Max modify mode
			subobjectlevel = 2
			)
		)	

		)
	"Edit Edges":(

		If $.modifiers[1] == undefined then
		(
		Max modify mode
		subobjectlevel = 3
		)
		else
		(
		if Querybox "Collapse" beep:yes then (
			
			local obj = $
			Converttomesh $
			select obj
			Max modify mode
			subobjectlevel = 3
			)
		)	

		)
	
	"Convert to Mesh":(
	local obj = $
	Converttomesh $
	select obj
	)
	
	"Convert to Nurbs":(
	local obj = $
	ConverttoNurbsSurface $
	Select obj
	)
	
	
	"Convert to Nurbs Curve":(
	local obj = $
	ConverttoNurbsCurve $
	select obj
	)
	
	"Convert to Nurbs Surface":(
		Local obj = $
		ConverttoNurbsCurve obj
		ConvertToNurbsSurface obj
		Max Modify Mode
		select obj
		)
		
			
	"Extrude": 
		(
			addModifier selection (Extrude amount:30)
		)
		"Cast Shadows:On":selection.castshadows = true
		"Cast Shadows:Off":selection.castshadows = false
		"Light Properties:":(
	
		Rollout LightRoll "Lights"
		(
	
Group "Light Properties"
		(
		CheckBox LON "ON:"Checked:$.on
		ColorPicker LC "Light Color:" color:$.color offset:[50,-22]
		Spinner mt "Multiplier:" range:[-50,50,$.multiplier]width:90 offset:[-30,0] 
		Checkbox CS "CastShadows"checked:$.castshadows
		Button upd "Update" Across:3
		Button pst "Paste"
		Button CL "Ok" width:20 Align:#right 
		
		)
		on upd pressed do
		(
		if isKindOf $ Light then
			(			
			lc.color = $.color
			cs.checked = $.castshadows
			mt.value = $.multiplier
			lon.checked = $.on
			)
			Else
			(
			Messagebox "A Light needs to be selected!"
			)
		

		)
			on pst pressed do
		(
		if isKindOf $ Light then
			(			
			$.color = lc.color 
			$.castshadows = cs.checked 
			$.multiplier = mt.value 
			$.on = lon.checked 
			)
			Else
			(
			Messagebox "A Light needs to be selected!"
			)
		

		)

		
	
	On cl pressed do
		(
		CloseRolloutFloater NW 
		)
		on LC changed color do (
		If isKindof $ Light then $.color = color
		)
		
		on cs changed state do (
			If isKindof $ Light then $.castshadows = state
			)
		on mt changed value do (
			If isKindof $ Light then $.multiplier = value
			) 
		on lon changed state do (
			If isKindof $ Light then $.on = state
			)
		)
		
		If nw !=undefined then
			(
			RemoveRollout Lightroll NW
			CloseRolloutFloater NW
			NW = NewrolloutFloater "LightBoy" 200 180
			Addrollout LightRoll NW
			lightroll.lc = $.color
			lightroll.cs = $.castshadows
			lightroll.mt = $.multiplier
			lightroll.lon = $.on
			)
			else
			(
			NW = NewrolloutFloater "LightBoy" 200 180
			Addrollout LightRoll NW
			)
		)
	)
		
)

-- filter function for adding the menu items 
fn flt_items = 
(
	-- Make sure to delete all the items in the array
	while (menu_items.count > 0) do deleteItem menu_items 1	
	
	-- Add the menu item only if it is a shape object
	if isKindOf $ Shape then
	(
		append menu_items "Convert to Nurbs Curve"
		append menu_items "Convert to Nurbs Surface"
	)
	
	-- Add all the generic menu items
	--append menu_items  "Scale Twice"
	--append menu_items  "Scale Half"


	if isKindOf $ Light then
	(
		append menu_items "Cast Shadows:On"
		append menu_items "Cast Shadows:Off"
		append menu_items "Light Properties:"
	)
	
	if Classof $ == Sphere then
	(
		append menu_items "Convert to Mesh"
		append menu_items "Convert to Nurbs"
	)
	
	if Classof $ == Box then
	(
		append menu_items "Convert to Mesh"
		append menu_items "Convert to Nurbs"
	)
	if Classof $ == Cylinder then
	(
		append menu_items "Convert to Mesh"
		append menu_items "Convert to Nurbs"
	)
	
	if Classof $ == Torus then
	(
		append menu_items "Convert to Mesh"
		append menu_items "Convert to Nurbs"
	)
	if Classof $ == Teapot then
	(
		append menu_items "Convert to Mesh"
		append menu_items "Convert to Nurbs"
	)
	if Classof $ == Cone then
	(
		append menu_items "Convert to Mesh"
		append menu_items "Convert to Nurbs"
	)
	if Classof $ == GeoSphere then
	(
		append menu_items "Convert to Mesh"
		append menu_items "Convert to Nurbs"
	)
	if Classof $ == Tube then
	(
		append menu_items "Convert to Mesh"
		append menu_items "Convert to Nurbs"
	)
	if Classof $ == Pyramid then
	(
		append menu_items "Convert to Mesh"
		append menu_items "Convert to Nurbs"
	)
	if Classof $ == Prism then
	(
		append menu_items "Convert to Mesh"
		append menu_items "Convert to Nurbs"
	)

	
	if classof $ == Editable_Mesh then
	(
	
		append menu_items "Edit Vertices"
		append menu_items "Edit Faces"
		append menu_items "Edit Edges"
		
	)
	If Classof $ == CV_surf then
		(
			append menu_items "Edit CV's"
		)



)




registerRightClickMenu menu_items fnSelected filter:flt_items

--Uncomment the following to unRegister the right_click functions--
--unregisterRightClickMenu fnSelected
