use <text_on/text_on.scad>

card_width = 85;
card_height = 55;
card_thickness = 0.254;

line_one = "Brendan M. Sleight";
line_two = "M: 07971032605";
line_three = "Print@barwap.com";
text_size = 5;

card_extra_circumference = 5;
pi = 3.1415;

emboss_thickness_text = 2.0;
circumference = card_width + card_extra_circumference;
cylinder_diameter = circumference / pi;
cylinder_radius = cylinder_diameter / 2;
gear_height = 2;

holder_gap = 0.2;
holder_thickness = 5;

$fn=180;



module roller()
{
    cylinder(r=cylinder_radius,h=card_height, center=true);
}

module rollerText(gap=0)
{
    extrusion_height = gap + emboss_thickness_text;
    text_on_cylinder(line_one, [0,0,10], r=cylinder_radius, h=card_height, spacing=1, cylinder_center=true, extrusion_height=extrusion_height, size=text_size);
    text_on_cylinder(line_two, [0,0,0], r=cylinder_radius, h=card_height, spacing=1, cylinder_center=true, extrusion_height=extrusion_height, size=text_size);
    text_on_cylinder(line_three, [0,0,-10], r=cylinder_radius, h=card_height, spacing=1, cylinder_center=true, extrusion_height=extrusion_height, size=text_size);
}

module rollerStop()
{
    translate([0, cylinder_radius, 0]) cube([1, 2, card_height], center=true);
}

module rollerJutting()
{
    difference()
    {
        union()
        {
            roller();
*            rollerText(gap=-0.1);
            rollerStop();
            gearPair();

        }
        cutouts();
    }    
}

module rollerIndent()
{
    difference()
    {
        union()
        {
            mirror([1,0,0]) difference()
            {
                roller();
*                rollerText(gap=+0.1);
                rollerStop();
            }
            gearPair(g_rotate=true);
        }
        cutouts();
    }
}

module cutouts(c_gap=0)
{
        translate([0,0,-card_height/2-gear_height*2.25]) cutout(c_gap=c_gap);
        translate([0,0,card_height/2+gear_height*2.25]) rotate([180,0,0]) cutout(c_gap=c_gap);
}

module cutout(c_gap=0)
{
    translate([0,0,5/2-0.1-c_gap]) cylinder(h = 5-c_gap, d1 = 20-c_gap*2, d2 = 20-5-c_gap*2, center = true);
}


module gearPair(g_rotate=false)
{
    translate([0,0,card_height/2+gear_height*1.125]) gearLink(g_rotate=g_rotate);
    translate([0,0,-card_height/2-gear_height*1.125]) gearLink(g_rotate=g_rotate);
}

module gearLink(g_radius=cylinder_radius+(card_thickness/2+emboss_thickness_text/2), g_rotate=false)
{
    render() rotate([180,0,0]) difference()
    {
        union()
        {
 *           gearLinkPlain(g_radius=g_radius, g_rotate=g_rotate);
 *           translate([0,0,gear_height+gear_height*(1.25/2)]) cylinder(r1=g_radius, r2=cylinder_radius,h=gear_height*1.25, center=true);
           translate([0,0,0]) cylinder(r1=g_radius, r2=cylinder_radius,h=gear_height*2.25, center=true);

        }
        union()
        {
            translate([0,0,-gear_height*2]) scale([1,1,5]) difference()
            {
                cylinder(r=g_radius+10,h=gear_height,centre=true);
               translate([0,0,-gear_height/2]) scale([1,1,2]) gearLinkPlain(g_radius=g_radius, g_rotate=g_rotate);
            }
        }
    }
}


module gearLinkPlain(g_radius=1, g_rotate=false)
{
    teeth = 28;
    angle = 360/(teeth*2);
    step = (g_radius * tan(angle/2)) / (1 +  (tan(angle/2))  ) *2  ;
    echo("step ", step);
    echo("g_radius",g_radius); 
//    rotate([0,0,360/23]) 
    if (g_rotate == true)
        rotate([0,0,360/teeth/2]) gear(teeth,step,2);
    else
        gear(teeth,step,gear_height);
}



module gear(teeth, step, height=0.2) {
    angle = 360/(teeth*2);
    radius = (step/2) / sin(angle/2);
    apothem = (step/2) / tan(angle/2);
    
    module circles() {
        for (i = [1:teeth])
            rotate(i * angle * 2) translate([radius,0,0]) circle(step/2);
    }
    
    linear_extrude(height) difference() {
        union() {
            circle(apothem);
            circles();
        }
        rotate(angle) circles();
    }
    echo(apothem+step/2);
}

module holder(g_radius=cylinder_radius+(card_thickness/2+emboss_thickness_text/2))
{
    holder_x = g_radius*4;
    difference()
    {
        cube([holder_x+holder_thickness*2, holder_thickness, holder_thickness*2+card_height+gear_height*4.5], center=true);
        cube([holder_x+holder_gap*2, holder_thickness*2+holder_gap*2, card_height+gear_height*4.5+holder_gap*2], center=true);
    }
    translate([cylinder_radius+(card_thickness/2+emboss_thickness_text/2)/2, 0, 0]) cutouts(c_gap=0.5);
    translate([-cylinder_radius-(card_thickness/2+emboss_thickness_text)/2, 0, 0])  cutouts(c_gap=0.5);
}


module machine()
{
    translate([cylinder_radius+(card_thickness/2+emboss_thickness_text/2)/2, 0, 0]) rollerJutting();
    translate([-cylinder_radius-(card_thickness/2+emboss_thickness_text)/2, 0, 0]) rollerIndent(); 
    holder();
}

module machine_print()
{
    translate([cylinder_radius+(card_thickness/2+emboss_thickness_text/2)/2 + 2, 0, 0]) rollerJutting();
    translate([-cylinder_radius-(card_thickness/2+emboss_thickness_text)/2 - 2 , 0, 0]) rollerIndent(); 
    translate([0 , 0, -card_height/2-gear_height+10]) rotate([90,0,0]) holder();
    
}


machine();
