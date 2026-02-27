/* [Text Settings] */
// The large text at the bottom
Bottom_Text = "Space";
// The smaller text on top
Top_Text = "Layered";
// Force all text to be Uppercase?
Force_Uppercase = true; 

/* [Font Settings] */
// Font name (e.g. Arial, Impact, Verdana)
Font_Name = "Arial";
// Font Style (Bold, Black, Regular)
Font_Style = "Black";

/* [Sizing & Positioning] */
// Size of the bottom text
Bottom_Size = 35;
// Size of the top text
Top_Size = 12;
// Space between the two lines of text (negative numbers make them overlap)
Vertical_Spacing = 1;

/* [Dimensions] */
// Thickness of the colored base (mm)
Base_Thickness = 20;
// How much the text sticks out above the base (mm)
Text_Thickness = 2;
// How wide the bubble border is around the text (mm)
Border_Width = 4;

/* [Colors] */
Base_Color = "#E91E63"; // Pinkish
Text_Color = "#FFFFFF"; // White

/* [Hidden] */
$fn = 60; 

// --- HELPER FUNCTIONS ---

// Function to convert string to uppercase
function to_upper(str) = chr([for(i = [0:len(str)-1]) let(c=ord(str[i])) (c>=97 && c<=122) ? c-32 : c]);

// Function to select text based on the toggle
function get_text(str) = Force_Uppercase ? to_upper(str) : str;

// --- MODULES ---

module text_layout_2d() {
    // Bottom Text
    translate([0, 0, 0])
        text(get_text(Bottom_Text), size=Bottom_Size, font=str(Font_Name, ":style=", Font_Style), halign="center", valign="baseline");

    // Top Text
    translate([0, Bottom_Size + Vertical_Spacing, 0])
        text(get_text(Top_Text), size=Top_Size, font=str(Font_Name, ":style=", Font_Style), halign="center", valign="baseline");
}

// --- ASSEMBLY ---

// 1. The Colored Base
color(Base_Color)
linear_extrude(Base_Thickness) {
    // Create the bubble outline around the text
    offset(r = Border_Width) {
        // Smooth out sharp inner corners
        offset(r = -2) offset(r = 2) { 
            text_layout_2d();
        }
    }
}

// 2. The Raised White Text
color(Text_Color)
translate([0, 0, Base_Thickness])
linear_extrude(Text_Thickness) {
    text_layout_2d();
}