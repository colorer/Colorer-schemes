-- This script is a basic test to show how to use the new functions added
-- when "MouseTrak.dlx" is placed in you plugins directory.

-- Steps
--	1. Create a Sphere
--	2. Create a cylinder with a small radius (Hair Like)
--	3. Run the MouseTrack.ms script
--	4. Choose "Spray" in the Moustrack utility
--	5. Then under Geometry Spray choose "pick Surface" 
--	6. Choose the Sphere
--	7. Then hit "Pick spray geometry"
--	8. and choose the cylinder
--	9. Now as you move the mouse over the sphere pressing the left mouse button,
--	it will draw cylinders on the sphere.

--Script and plugin code by John Wainwright.

	



utility mesh_painter "Mesh Painter"
(
	checkbutton spray "Spray" tooltip:"Spray geometry over surface" offset:[-5,0] across:3
	checkbutton sel "Select" tooltip:"Select faces by painting"
	checkbutton sculpt "Sculpt" tooltip:"Sculpt mesh surface" offset:[5,0]
	
	rollout spray_ro "Geometry Spray"
	(
		local surf, geom
		pickbutton pick_surf "Pick surface"
		pickbutton pick_geom "Pick spray geometry"
		checkbutton do_spray "Spray"
		
		fn spray_track msg ir obj faceNum shift ctrl alt =
		(
			if msg == #mouseMove and ir != undefined then
			(
				local b = copy geom pos:ir.pos
				b.dir = ir.dir
			)
			if msg == #mouseAbort then ok else #continue
		)

		on pick_surf picked obj do surf = obj
		on pick_geom picked obj do geom = obj
		on do_spray changed state do 
		(
			mouseTrack on:surf trackCallBack:spray_track
			do_spray.checked = false
		)
	)
	
	rollout sel_ro "Face Select"
	(
		local surf
		pickbutton pick_surf "Pick surface"
		checkbutton do_sel "Select" tooltip:"press <alt> key to subtract from selection"
		
		fn sel_track msg ir obj faceNum shift ctrl alt =
		(
			if msg == #mouseMove and faceNum != undefined then
			(
				if not alt then
					setFaceSelection obj #(faceNum) keep:true
				else
				(
					local s = getFaceSelection obj,
					      i = findItem s faceNum
					if i > 0 then setFaceSelection obj (deleteItem s i)
				)
				update obj
			)
			if msg == #mouseAbort then ok else #continue
		)

		on pick_surf picked obj do surf = obj
		on do_sel changed state do 
		(
			if classOf surf.baseObject != editable_mesh then convertToMesh surf
			select surf
			max modify mode
			subObjectLevel = 2
			mouseTrack on:surf trackCallBack:sel_track
			do_sel.checked = false
		)
	)
	
	rollout sculpt_ro "Sculpt Surface"
	(
		local surf, last_face
		pickbutton pick_surf "Pick surface"
		checkbutton do_sculpt "Sculpt" tooltip:"drag to pull; <shift>-drag push surface"
		
		fn sculpt_track msg ir obj faceNum shift ctrl alt =
		(
			if msg == #mouseMove and faceNum != undefined and faceNum != last_face then
			(
				local f = getFace obj faceNum, dir = if shift then -ir.dir else ir.dir
				setVert obj f.x ((getVert obj f.x) + dir * 3)
				setVert obj f.y ((getVert obj f.y) + dir * 3)
				setVert obj f.z ((getVert obj f.z) + dir * 3)
				last_face = faceNum
				update obj
			)
			if msg == #mouseAbort then ok else #continue
		)

		on pick_surf picked obj do surf = obj
		on do_sculpt changed state do 
		(
			if classOf surf.baseObject != editable_mesh then convertToMesh surf
			last_face = undefined
			mouseTrack on:surf trackCallBack:sculpt_track
			do_sculpt.checked = false
		)
	)
	
	on spray changed state do 
	(
		sel.checked = sculpt.checked = false
		removeRollout sel_ro
		removeRollout sculpt_ro
		(if state then addRollout else removeRollout) spray_ro
	)
	
	on sel changed state do 
	(
		spray.checked = sculpt.checked = false
		removeRollout spray_ro
		removeRollout sculpt_ro
		(if state then addRollout else removeRollout) sel_ro
	)
	
	on sculpt changed state do 
	(
		spray.checked = sel.checked = false
		removeRollout spray_ro
		removeRollout sel_ro
		(if state then addRollout else removeRollout) sculpt_ro
	)
	
	on mesh_painter close do 
	(
		removeRollout spray_ro
		removeRollout sel_ro
		removeRollout sculpt_ro
	)
)