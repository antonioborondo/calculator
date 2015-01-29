/* Copyright 2014 Marvin Beckers <beckersmarvin@gmail.com>
*
* This file is part of Pantheon Calculator
*
* Pantheon Calculator is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Pantheon Calculator is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Pantheon Calculator. If not, see http://www.gnu.org/licenses/.
*/

using Granite.Widgets;
using PantheonCalculator.Core;

namespace PantheonCalculator {
    public class MainWindow : Gtk.Window {
        private Gtk.HeaderBar       headerbar;
        private Gtk.Grid            main_grid;
        private Gtk.Entry           entry;

        // widgets I need to access
        private Gtk.Image           extended_img_1;
        private Gtk.Image           extended_img_2;
        private Gtk.Button          button_calc;
        private Gtk.Button          button_history;
        private Gtk.Button          button_ans;
        private Gtk.Button          button_undo;
        private Gtk.Button          button_del;
        private Gtk.ToggleButton    button_extended;
        private Gtk.InfoBar?        infobar;
        private Gtk.Button          button_pow;
        private Gtk.Box             margin_box;

        private List<weak Gtk.Button>    basic_button_list;
        private List<weak Gtk.Button>    extended_button_list;

        private List<History?>      history;
        private int                 position;

        //define the decimal places
        private int round = 5;

        public struct History { string exp; string output; }

        private string[] regular_buttons = {   "0", "1", "2", "3", "4", "5", 
                                                "6", "7", "8", "9", "0", " + ",
                                                " − ", " × ", " ÷ ", "%", ".", "(", 
                                                ")", "^", "π"};

        private string[] function_buttons = {  "sin", "cos", "tan", "√", "sinh", "cosh",
                                                "tanh" , "sqrt"};

        public MainWindow () {
            set_resizable (false);
            window_position = Gtk.WindowPosition.CENTER;

            history = new List<History?> ();
            position = 0;

            build_titlebar ();
            build_ui ();
        }

        private void build_titlebar () {
            headerbar = new Gtk.HeaderBar ();  
            headerbar.get_style_context ().add_class ("primary-toolbar");
            headerbar.show_close_button = true;
            headerbar.set_title (_("Calculator"));
            set_titlebar (headerbar); 

            extended_img_1 = new Gtk.Image.from_icon_name ("pane-hide-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            extended_img_2 = new Gtk.Image.from_icon_name ("pane-show-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            var history_img = new Gtk.Image.from_icon_name ("document-open-recent-symbolic", Gtk.IconSize.LARGE_TOOLBAR);

            button_extended = new Gtk.ToggleButton ();
            button_extended.set_property ("image", extended_img_1);
            button_extended.set_tooltip_text (_("Show extended functionality"));
            button_extended.set_relief (Gtk.ReliefStyle.NONE);
            button_extended.toggled.connect (toggle_grid);

            button_history = new Gtk.Button ();
            button_history.set_property ("image", history_img);
            button_history.set_tooltip_text (_("History"));
            button_history.set_relief (Gtk.ReliefStyle.NONE);
            button_history.set_sensitive (false);
            button_history.clicked.connect (show_history);

            headerbar.pack_end (button_extended);
            headerbar.pack_end (button_history);
        }

        private void build_ui () {
            main_grid = new Gtk.Grid ();
            main_grid.orientation = Gtk.Orientation.VERTICAL;
            main_grid.set_column_spacing (2);
            main_grid.set_row_spacing (2);
            main_grid.margin = 5;
            main_grid.expand = true;
            main_grid.halign = Gtk.Align.CENTER;

            build_basic_ui ();
            build_extended_ui ();

            add (main_grid);
            show_all ();

            toggle_grid (button_extended);
        }

        private void build_basic_ui () {
            entry = new Gtk.Entry ();
            entry.set_text ("");

            button_calc = new Gtk.Button.with_label ("=");
            button_ans = new Gtk.Button.with_label ("ANS");
            button_undo = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            button_del = new Gtk.Button.with_label ("C");

            var button_add = new Gtk.Button.with_label (" + ");
            var button_sub = new Gtk.Button.with_label (" − ");
            var button_mult = new Gtk.Button.with_label (" × ");
            var button_div = new Gtk.Button.with_label (" ÷ ");

            var button_0 = new Gtk.Button.with_label ("0");
            var button_point = new Gtk.Button.with_label (".");
            var button_percent = new Gtk.Button.with_label ("%");
            var button_1 = new Gtk.Button.with_label ("1");
            var button_2 = new Gtk.Button.with_label ("2");
            var button_3 = new Gtk.Button.with_label ("3");

            var button_4 = new Gtk.Button.with_label ("4");
            var button_5 = new Gtk.Button.with_label ("5");
            var button_6 = new Gtk.Button.with_label ("6");

            var button_7 = new Gtk.Button.with_label ("7");
            var button_8 = new Gtk.Button.with_label ("8");
            var button_9 = new Gtk.Button.with_label ("9");

            button_ans.set_sensitive (false);

            //add style context to widgets
            entry.get_style_context ().add_class ("h2");
            button_del.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            button_add.get_style_context ().add_class ("h3");
            button_sub.get_style_context ().add_class ("h3");
            button_mult.get_style_context ().add_class ("h3");
            button_div.get_style_context ().add_class ("h3");
            button_calc.get_style_context ().add_class ("h2");
            button_calc.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            //set tooltips for widgets
            button_del.set_tooltip_text (_("Clear entry"));
            button_undo.set_tooltip_text (_("Backspace"));
            button_ans.set_tooltip_text (_("Add last result"));

            //set size for some widgets to get desired layout
            entry.set_size_request (0, 45);
            button_0.set_size_request (65, 45);
            button_1.set_size_request (65, 45);
            button_4.set_size_request (65, 45);
            button_7.set_size_request (65, 45);

            button_undo.set_size_request (65, 45);
            button_del.set_size_request (65, 45);
            button_percent.set_size_request (65, 45);
            button_add.set_size_request (65, 45);

            //attach all widgets
            main_grid.attach (entry, 0, 0, 4, 1);

            entry.changed.connect (remove_error);
            entry.activate.connect (button_calc_clicked);

            basic_button_list.append (button_del);
            basic_button_list.append (button_7);
            basic_button_list.append (button_4);
            basic_button_list.append (button_1);
            basic_button_list.append (button_0);

            basic_button_list.append (button_undo);
            basic_button_list.append (button_8);
            basic_button_list.append (button_5);
            basic_button_list.append (button_2);
            basic_button_list.append (button_point);

            basic_button_list.append (button_percent);
            basic_button_list.append (button_9);
            basic_button_list.append (button_6);
            basic_button_list.append (button_3);
            basic_button_list.append (button_ans);

            basic_button_list.append (button_div);
            basic_button_list.append (button_mult);
            basic_button_list.append (button_sub);
            basic_button_list.append (button_add);
            basic_button_list.append (button_calc);

            int pos = 0;
            foreach (Gtk.Button b_button in basic_button_list) {
                main_grid.attach (b_button, (pos / 5), (pos % 5 + 1), 1, 1);
                b_button.clicked.connect (button_clicked);
                pos++;
            }
        }

        private void build_extended_ui () {
            button_pow = new Gtk.Button ();
            var pow_label = new Gtk.Label ("x<sup>y</sup>");
            pow_label.set_use_markup (true);
            button_pow.add (pow_label);

            var button_sin = new Gtk.Button.with_label ("sin");
            var button_cos = new Gtk.Button.with_label ("cos");
            var button_tan = new Gtk.Button.with_label ("tan");
            var button_pi = new Gtk.Button.with_label ("π");
            var button_par_left = new Gtk.Button.with_label ("(");

            var button_sr = new Gtk.Button.with_label ("√");
            var button_sinh = new Gtk.Button.with_label ("sinh");
            var button_cosh = new Gtk.Button.with_label ("cosh");
            var button_tanh = new Gtk.Button.with_label ("tanh");
            var button_e = new Gtk.Button.with_label ("e");
            var button_par_right = new Gtk.Button.with_label (")");

            //set size for some widgets to get desired layout
            button_par_left.set_size_request (65, 45);
            button_par_right.set_size_request (65, 45);

            margin_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            margin_box.set_size_request (0, 12);
            main_grid.attach (margin_box, 4, 0, 1, 6);

            extended_button_list.append (button_par_left);
            extended_button_list.append (button_pow);
            extended_button_list.append (button_sin);
            extended_button_list.append (button_cos);
            extended_button_list.append (button_tan);
            extended_button_list.append (button_pi);

            extended_button_list.append (button_par_right);
            extended_button_list.append (button_sr);
            extended_button_list.append (button_sinh);
            extended_button_list.append (button_cosh);
            extended_button_list.append (button_tanh);
            extended_button_list.append (button_e);

            int pos = 0;
            foreach (Gtk.Button e_button in extended_button_list) {
                main_grid.attach (e_button, (pos / 6 + 5), (pos % 6), 1, 1);
                e_button.clicked.connect (button_clicked);
                pos++;
            }
        }

        private void button_clicked (Gtk.Button btn) {
            if (btn == button_calc)
                button_calc_clicked ();
            else if (btn == button_undo)
                button_undo_clicked ();
            else if (btn == button_del)
                button_del_clicked ();
            else if (btn == button_ans)
                button_ans_clicked ();
            else {
                string label = btn.get_label ();
                if (btn == button_pow)
                    label = "^";

                bool is_function = label in function_buttons;
                bool is_regular = label in regular_buttons;
                
                if (!is_function && !is_regular)
                    return;

                int selection_start = -1;
                int selection_end = -1;
                int new_position = entry.get_position ();

                if (is_function && entry.get_selection_bounds (out selection_start, out selection_end)) {
                    string selected_text = entry.get_chars (selection_start, selection_end);
                    string function_call = label + "(" + selected_text + ")";
                    entry.delete_text (selection_start, selection_end);
                    entry.insert_text (function_call, -1, ref selection_start);
                    new_position += function_call.length;
                } else {
                    entry.insert_at_cursor (label);
                    new_position += label.length;
                }

                entry.grab_focus ();
                entry.set_position (new_position);
            }
        }

        private void button_calc_clicked () {
            position = entry.get_position ();
            remove_error ();
            if (entry.get_text () != "") {
                try {
                    var output = Evaluation.evaluate (entry.get_text (), round);
                    if (entry.get_text () != output) {
                        history.append (History () { exp = entry.get_text (), output = output } );
                        entry.set_text (output);
                        button_history.set_sensitive (true);
                        button_ans.set_sensitive (true);

                        position = output.length;
                    }
                } catch (OUT_ERROR e) {
                    infobar = new Gtk.InfoBar ();
                    infobar.get_content_area ().add (new Gtk.Label (e.message));
                    infobar.set_show_close_button (false);
                    infobar.set_message_type (Gtk.MessageType.ERROR);

                    main_grid.attach (infobar, 0, 0, 2, 1);
                    infobar.show_all ();
                }
            }

            entry.grab_focus ();
            entry.set_position (position);
        }

        private void button_undo_clicked () {
            position = entry.get_position ();
            if (entry.get_text ().length > 0) {
                string new_text = "";
                int index = 0;
                unowned unichar c;
                List<unichar> news = new List<unichar> ();

                for (int i = 0; entry.get_text ().get_next_char(ref index, out c); i++) {
                    if (i+1 != position)
                        news.append (c);
                }

                foreach (unichar u in news) {
                    new_text += u.to_string ();
                }

                entry.set_text (new_text);
            }

            entry.grab_focus ();
            entry.set_position (position - 1);
        }

        private void button_del_clicked () {
            position = 0;
            entry.set_text ("");
            set_focus (entry);
            remove_error ();

            entry.grab_focus ();
            entry.set_position (position);
        }

        private void button_ans_clicked () {
            position = entry.get_position ();
            if ((int) history.length () > 0) {
                unowned List<History?> last = history.last ();
                history_added (last.data.output.to_string ());
            }
        }

        private void toggle_grid (Gtk.ToggleButton button) {
            position = entry.get_position ();
            if (button.get_active ()) {
                //show extended functionality
                button.set_property ("image", extended_img_2);
                button.set_tooltip_text (_("Hide extended functionality"));

                margin_box.show ();
                foreach (Gtk.Button e_button in extended_button_list)
                    e_button.show ();
            } else {
                //hide extended functionality
                button.set_property ("image", extended_img_1);
                button.set_tooltip_text (_("Show extended functionality"));

                margin_box.hide ();
                foreach (Gtk.Button e_button in extended_button_list)
                    e_button.hide ();
            }
            //focusing button_calc because without a new focus it will cause weird window drawing problems.
            entry.grab_focus ();
            entry.set_position (position);
        }

        private void show_history (Gtk.Button button) {
            position = entry.get_position ();

            button_history.set_sensitive (false);

            var history_dialog = new HistoryDialog (history);
            history_dialog.added.connect (history_added);
            history_dialog.hide.connect (() => button_history.set_sensitive (true));
        }

        private void history_added (string input) {
            entry.insert_at_cursor (input);
            position += input.length;
            entry.grab_focus ();
            entry.set_position (position);
        }

        private void remove_error () {
            if (infobar != null)
                infobar.hide ();
        }
    }
}