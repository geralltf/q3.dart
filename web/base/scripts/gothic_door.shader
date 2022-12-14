//**********************************************************************//
//	gothic_door.shader created from scratch for Q3Radiant		//
//	by Eutectic - 21 Jan 2000					//
//									//
//	TOTAL SHADERS: 4						//
//	NO. OF BROKEN SHADERS/COMMENTED OUT: 0				//
//	NO. OF WORKING SHADERS WITH DUPLICATE ENTRIES: 0		//
//	NO. OF WORKING SHADERS THAT DIDN'T APPEAR IN EDITOR: 0		//
//	SHADERS THAT DIDN'T BELONG HERE AND MOVED TO PROPER FILE: 0	//
//	SHADERS THAT BELONGED HERE BUT WERE IN ANOTHER FILE: 4		//
//	textures/gothic_door/door02_bred2_shiny				//
//	textures/gothic_door/door02_eblue2_shiny			//
//	textures/gothic_door/door02_i_ornate5_fin			//
//	textures/gothic_door/skullarch_b				//
//**********************************************************************//

textures/gothic_door/door02_bred2_shiny
{              
qer_editorimage textures/gothic_door/door02_bred2.tga 
	{
		map $lightmap
		rgbGen identity
	}


        {
		map textures/gothic_door/door02_bred2.tga
                blendFunc GL_dst_color GL_SRC_ALPHA
		alphagen lightingspecular
		rgbGen identity
	}

}

textures/gothic_door/door02_eblue2_shiny
{              
qer_editorimage textures/gothic_door/door02_eblue2.tga

	{
		map $lightmap
		rgbGen identity
	}


        {
		map textures/gothic_door/door02_eblue2.tga
                blendFunc GL_dst_color GL_SRC_ALPHA
		alphagen lightingspecular
		rgbGen identity
	}

}

textures/gothic_door/door02_i_ornate5_fin
{
	qer_editorimage textures/gothic_door/door02_i_ornate5_fin.tga
	{
		map $lightmap
		rgbgen identity      
	}
	
	{
		map textures/gothic_door/door02_i_ornate5_fin.tga
		blendFunc GL_DST_COLOR GL_SRC_ALPHA
		rgbGen identity
		alphaGen lightingSpecular
	}
}

textures/gothic_door/skullarch_b
{

        {
		map textures/sfx/firegorre.tga
                tcmod scroll 0 1
                tcMod turb 0 .25 0 5.6
                tcmod scale 1.5 1.5
                blendFunc GL_ONE GL_ZERO
                rgbGen identity
	}
       
	{
	        map textures/gothic_door/skullarch_b.tga
		blendFunc blend
	        rgbGen identity
	}
        {
		map $lightmap
                blendFunc filter
		rgbGen identity
	}
}

