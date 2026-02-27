/* [Primary Text] */
// The main family name
Surname = "BUTAY";
// Left top label
Label_Left = "MR";
// Right top label
Label_Right = "MRS";
// Left bottom label (e.g., Month)
Label_Bottom_Left = "06";
// Right bottom label (e.g., Year)
Label_Bottom_Right = "17";

/* [Features & Toggles] */
// Show the Mr & Mrs text?
Show_Titles = true;
// Show the Date numbers?
Show_Dates = true;

/* [Font & Sizing Settings] */
// Font name (You can now safely use standard fonts like Arial Black, Impact, etc.)
Font_Name = "Arial Black"; 
// General scale of the entire object
Global_Scale = 0.85;
// Thickness of the final 3D object (mm)
Thickness = 15;

/* [Hollow Settings] */
// How wide the spacing is between the letters
Letter_Spacing = 1.0;
// Depth of the text cut. (Set to 20 to cut all the way through, or less to leave a solid backing)
Hollow_Depth = 20; 

/* [Auto-Stencil Bridges (Fixes Floating Islands)] */
// Automatically add structural bridges so center pieces don't fall out
Enable_Bridges = true;
// Thickness of the connecting bridges (mm)
Bridge_Thickness = 1.2;
// Distance between the bridges (mm)
Bridge_Spacing = 10;
// Direction of the bridges
Bridge_Style = "Grid"; // [Grid, Vertical, Horizontal]

/* [Layout Tweaks] */
// Size of the hollow surname
Surname_Size = 22;
// Width of the solid bar that holds the surname
Bar_Width = 130;
// Height of the solid bar
Bar_Height = 28;
// Roundness of the bar corners (0 for sharp corners)
Bar_Corner_Radius = 5; 
// Move the bar up or down
Bar_Y_Offset = -15;
// General size for MR, MRS, and Dates
Label_Size = 14;

/* [Positioning: MR & MRS (Middle of Heart)] */
// Nudge MR Left/Right
MR_X = 0;
// Nudge MR Up/Down
MR_Y = 30;
// Tilt MR
MR_Rot = 0;

// Nudge MRS Left/Right
MRS_X = 0;
// Nudge MRS Up/Down
MRS_Y = 10;
// Tilt MRS
MRS_Rot = 0;

/* [Positioning: Date Numbers (Top Lobes)] */
// Nudge Month Left/Right
Num_Left_X = -20;
// Nudge Month Up/Down 
Num_Left_Y = 50;

// Nudge Year Left/Right
Num_Right_X = 20;
// Nudge Year Up/Down 
Num_Right_Y = 50;


/* [Hidden] */
$fn = 60;
heart_base_size = 100 * Global_Scale;

// --- HELPER FUNCTIONS ---
// Function to convert any string to uppercase automatically
function to_upper(str) = chr([for(i = [0:len(str)-1]) let(c=ord(str[i])) (c>=97 && c<=122) ? c-32 : c]);

// --- 2D MODULES ---

// A stylized heart shape roughly centered
module heart_shape(size) {
    square_size = size * 0.65;
    radius = square_size / 2;
    
    // Adjusted to make the bottom point slightly wider
    translate([0, size*0.15, 0]) 
    union() {
        rotate([0, 0, 45]) 
            square([square_size, square_size], center=true);
        
        translate([-radius * cos(45), radius * sin(45), 0]) 
            circle(r=radius);
        translate([radius * cos(45), radius * sin(45), 0]) 
            circle(r=radius);
    }
}

// Module to create a bar with configurable rounded corners
module rounded_bar(w, h, r) {
    // Safe radius prevents breaking if user sets radius larger than half the height/width
    safe_r = min(r, w/2 - 0.1, h/2 - 0.1); 
    
    if (safe_r <= 0) {
        square([w, h], center=true);
    } else {
        // Offset trick creates perfectly rounded corners while maintaining exact total dimensions
        offset(r = safe_r)
            square([w - 2*safe_r, h - 2*safe_r], center=true);
    }
}

// Generates the pattern of thin lines to anchor the floating pieces
module bridge_pattern() {
    if (Bridge_Style == "Vertical" || Bridge_Style == "Grid") {
        for (x = [-150 : Bridge_Spacing : 150]) {
            translate([x, 0, 0]) square([Bridge_Thickness, 300], center=true);
        }
    }
    if (Bridge_Style == "Horizontal" || Bridge_Style == "Grid") {
        for (y = [-150 : Bridge_Spacing : 150]) {
            translate([0, y, 0]) square([300, Bridge_Thickness], center=true);
        }
    }
}

// 1. All Solid Positive Shapes (The Base)
module solid_base_2d() {
    union() {
        // The central heart backbone
        heart_shape(heart_base_size);
        
        // The solid horizontal bar for the Surname (Now using the rounded_bar module)
        translate([0, Bar_Y_Offset, 0])
            rounded_bar(Bar_Width * Global_Scale, Bar_Height * Global_Scale, Bar_Corner_Radius * Global_Scale);
    }
}

// 2. All Negative Shapes (The Cutouts) before bridges
module raw_hollow_cutouts_2d() {
    // The Surname (Forced to Uppercase)
    translate([0, Bar_Y_Offset, 0])
        text(to_upper(Surname), size=Surname_Size * Global_Scale, font=Font_Name, halign="center", valign="center", spacing=Letter_Spacing);

    // Render MR/MRS only if the toggle is checked
    if (Show_Titles) {
        translate([MR_X, MR_Y, 0])
        rotate([0, 0, MR_Rot]) 
            text(to_upper(Label_Left), size=Label_Size, font=Font_Name, halign="center", valign="center", spacing=Letter_Spacing);
        
        translate([MRS_X, MRS_Y, 0])
        rotate([0, 0, MRS_Rot]) 
            text(to_upper(Label_Right), size=Label_Size, font=Font_Name, halign="center", valign="center", spacing=Letter_Spacing);
    }

    // Render Dates only if the toggle is checked
    if (Show_Dates) {
        translate([Num_Left_X, Num_Left_Y, 0])
            text(to_upper(Label_Bottom_Left), size=Label_Size*0.9, font=Font_Name, halign="center", valign="center", spacing=Letter_Spacing);

        translate([Num_Right_X, Num_Right_Y, 0])
            text(to_upper(Label_Bottom_Right), size=Label_Size*0.9, font=Font_Name, halign="center", valign="center", spacing=Letter_Spacing);
    }
}

// 3. Apply the bridges to the cutouts
module finalized_cutouts_2d() {
    if (Enable_Bridges) {
        difference() {
            raw_hollow_cutouts_2d();
            // Subtracting the bridges from the HOLES means the bridges become SOLID in the final base
            bridge_pattern();
        }
    } else {
        raw_hollow_cutouts_2d();
    }
}


// --- FINAL 3D ASSEMBLY ---

color([0.8, 0.4, 0.4]) 
difference() {
    // 1. Render the solid base
    linear_extrude(height = Thickness)
        solid_base_2d();
    
    // 2. Calculate the cut depth based on user settings
    cut_z = (Hollow_Depth >= Thickness) ? -1 : Thickness - Hollow_Depth;
    cut_h = (Hollow_Depth >= Thickness) ? Thickness + 2 : Hollow_Depth + 1;
    
    // 3. Subtract the hollow cutouts (with bridges intact) from the top down
    translate([0, 0, cut_z])
        linear_extrude(height = cut_h)
            finalized_cutouts_2d(); 
}