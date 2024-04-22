% name:     Airborne Radar Model - "Symbolic Units" Build
% matver:   R2023b
% summary:  Models UAV radar system as part of university coursework
% author:   Chris Upchurch (chrisu@ucf.edu)
% notes:    - This class object is primarily used for development purposes.
%           - The runtime is terrible and might be missing a few calculation fixes
%             implemented in UAVRadarModel_NoSyms.
%           - Wherever possible, use UAVRadarModel_NoSyms class objects instead 
%             as it SIGNIFICANTLY improves runtime by removal of most (but not all)
%             use of MATLAB symbolic units for unit conversion assurance.

classdef UAVRadarModel < handle
    %% Object Inputs
    properties
        rdr_mode_strategy

        ant_bs_grazing_ang_mid {isUnit}
        ant_dim_elev {isUnit}
        ant_dim_azim {isUnit}
        ant_azim_fwd_look_half_angle {isUnit}
        ant_spin_rate {isUnit}
        ant_altitude {isUnit}

        tx_freq {isUnit}
        tx_power {isUnit}
        tx_pulse_width {isUnit}
        tx_prf {isUnit}
        tx_pcr {mustBeNumeric}

        t_fa {isUnit}
        scan_qty_on_tgt_intent {mustBeNumeric}
    end

    %% Private Property Defs

    properties (GetAccess = private, SetAccess = private)
        model_cache = configureDictionary("string", "sym");
    end

    %% Dependent Property Defs

    properties (Dependent)
        % rx_clutter_pwr_db_far {isUnit}
        % rx_clutter_pwr_db_mid {isUnit}
        % rx_clutter_pwr_db_near {isUnit}
        scan_fov_overlap_pct {isUnit}
        ant_bs_grazing_ang_far {isUnit}
        ant_bs_grazing_ang_near {isUnit}
        ant_hpbw_azimuth {isUnit}
        ant_hpbw_elevation {isUnit}
        avg_tgt_xs_area_far {isUnit}
        avg_tgt_xs_area_mid {isUnit}
        avg_tgt_xs_area_near {isUnit}
        bs_rng_far {isUnit}
        bs_rng_mid {isUnit}
        bs_rng_near {isUnit}
        clutter_eff_area_far {isUnit}
        clutter_eff_area_mid {isUnit}
        clutter_eff_area_near {isUnit}
        clutter_sigma0_db_far {mustBeNumeric}
        clutter_sigma0_db_mid {mustBeNumeric}
        clutter_sigma0_db_near {mustBeNumeric}
        clutter_to_noise_db_far {mustBeNumeric}
        clutter_to_noise_db_mid {mustBeNumeric}
        clutter_to_noise_db_near {mustBeNumeric}
        doppler_precision_far {mustBeNumeric}
        doppler_precision_mid {mustBeNumeric}
        doppler_precision_near {mustBeNumeric}
        doppler_time_on_target {isUnit}
        fov_area_approx {isUnit}
        fov_azimuth {isUnit}
        fov_range {isUnit}
        ifov_far {isUnit}
        ifov_mid {isUnit}
        ifov_near {isUnit}
        l_atm_oneway_db_far {mustBeNumeric}
        l_atm_oneway_db_mid {mustBeNumeric}
        l_atm_oneway_db_near {mustBeNumeric}
        l_atm_roundtrip_db_far {mustBeNumeric}
        l_atm_roundtrip_db_mid{mustBeNumeric}
        l_atm_roundtrip_db_near {mustBeNumeric}
        max_expected_doppler_freq_far {isUnit}
        max_expected_doppler_freq_mid {isUnit}
        max_expected_doppler_freq_near {isUnit}
        max_prf_supported {isUnit}
        min_spin_rate_supported {mustBeNumeric}
        nyquist_reqd_for_max_doppler_far {isUnit}
        nyquist_reqd_for_max_doppler_mid {isUnit}
        nyquist_reqd_for_max_doppler_near {isUnit}
        prf
        pulses_on_target {mustBeNumeric}
        pulse_azim_res_far {isUnit}
        pulse_azim_res_mid {isUnit}
        pulse_azim_res_near {isUnit}
        pulse_rng_res_far {isUnit}
        pulse_rng_res_mid {isUnit}
        pulse_rng_res_near {isUnit}
        p_det_multi_pulse_far {mustBeNumeric}
        p_det_multi_pulse_mid {mustBeNumeric}
        p_det_multi_pulse_near {mustBeNumeric}
        p_det_n_of_m_far {mustBeNumeric}
        p_det_n_of_m_mid {mustBeNumeric}
        p_det_n_of_m_near {mustBeNumeric}
        p_det_single_pulse_far {mustBeNumeric}
        p_det_single_pulse_mid {mustBeNumeric}
        p_det_single_pulse_near {mustBeNumeric}
        p_fa {mustBeNumeric}
        rdr_xfactor_far
        rdr_xfactor_mid
        rdr_xfactor_near
        rtt_far {isUnit}
        rtt_mid {isUnit}
        rtt_near {isUnit}
        rx_minus3dB_bw_predet {isUnit}
        rx_noise_power {isUnit}
        rx_noise_power_db {mustBeNumeric}
        rx_single_pulse_pwr_db_far {mustBeNumeric}
        rx_single_pulse_pwr_db_mid {mustBeNumeric}
        rx_single_pulse_pwr_db_near {mustBeNumeric}
        rx_single_pulse_pwr_far {isUnit}
        rx_single_pulse_pwr_mid {isUnit}
        rx_single_pulse_pwr_near {isUnit}
        swath_width {isUnit}
        tfa_tspin_ratio {mustBeNumeric}
        tgt_to_clutter_db_far {isUnit}
        tgt_to_clutter_db_mid {isUnit}
        tgt_to_clutter_db_near {isUnit}
        tgt_to_clutter_noise_db_far {isUnit}
        tgt_to_clutter_noise_db_mid {isUnit}
        tgt_to_clutter_noise_db_near {isUnit}
        tgt_to_clutter_noise_noncoh_multi_db_far {mustBeNumeric}
        tgt_to_clutter_noise_noncoh_multi_db_mid {mustBeNumeric}
        tgt_to_clutter_noise_noncoh_multi_db_near {mustBeNumeric}
        tgt_to_noise_db_far {mustBeNumeric}
        tgt_to_noise_db_mid {mustBeNumeric}
        tgt_to_noise_db_near {mustBeNumeric}
        tgt_tracking_scan_qty {mustBeNumeric}
        time_on_target {isUnit}
        tx_ant_gain {mustBeNumeric}
        tx_ant_gain_db {mustBeNumeric}
        tx_duty_cycle {isUnit}
        t_spin {isUnit}
        t_sys {isUnit}
        t_warn {isUnit}
        worst_case_doppler_precision {mustBeNumeric}
        worst_case_max_expected_doppler_freq {isUnit}
        worst_case_nyquist_reqd_for_max_doppler {isUnit}
        worst_case_p_det_multi_pulse {mustBeNumeric}
        worst_case_pulse_rng_res {isUnit}
        worst_case_pulse_azim_res {isUnit}
        requirements_check
        goals_check
    end

    %% Constants

    properties (Constant)
        const_ant_tref = 290 * symunit("K");

        const_nofm_det_qty = 2;
        const_nofm_total_qty = 4;

        const_fwd_look_half_ang_max = 90 * symunit('deg');

        const_rcs_p1 = 5.0084e-06;
        const_rcs_p2 = -7.6230e-04;
        const_rcs_p3 = 3.1267e-02;
        const_rcs_p4 = -1.4949e-01;
        const_rcs_p5 = 2.34;

        const_clut_p1 = -4.3868e-06;
        const_clut_p2 = 0.00098614;
        const_clut_p3 = -0.071347;
        const_clut_p4 = 2.2443;
        const_clut_p5 = -44.959;

        const_alt_km_min = 5;
        const_alt_km_max = 15;

        const_ac_gnd_speed = 115 * symunit("kmh");
        const_tgt_speed_max = 200 * symunit("kmh");
        const_tgt_speed_min = 50 * symunit("kmh");

        const_ant_rpm_max = 180 * symunit("rpm");

        const_latm_37g_1way_dbkm = -0.05;
        const_latm_90g_1way_dbkm = -0.2;
        const_latm_150g_1way_dbkm = -0.6;
        const_latm_eff_max_altitude = 5 * symunit("km");

        const_tsys_37g_degk = 500;
        const_tsys_90g_degk = 700;
        const_tsys_150g_degk = 1000;

        const_requirements_json_file = 'data\customer_requirements.json'
    end

    %% Static Functions

    methods (Static)
        function val = ratio2db(ratio)
            val = 10 * log10(separateUnits(vpa(ratio)));
        end

        function val = db2ratio(db)
            if isUnit(db)
                error('Function input db must not be a symbolic unit.')
            end
            val = 10 ^ (db / 10);
        end

        function val = freq2wavelen(freq)
            u = symunit;

            if checkUnits(freq == u.Hz, 'compatible')
                freq = unitConvert(freq, (1 / u.sec));
            else
                error('Input argument must be compatible with symbolic unit "Hz".')
            end

            val = unitConvert(u.c_0, (u.m / u.s)) / freq;
        end
    end

    %% Dynamic Functions

    methods
        %% Constructor
        function obj = UAVRadarModel(rdr_mode_strategy, opts)
            arguments
                rdr_mode_strategy (1, 1) string
                opts.ant_bs_grazing_ang_mid (1, 1) sym
                opts.ant_dim_elev (1, 1) sym
                opts.ant_dim_azim (1, 1) sym
                opts.ant_azim_fwd_look_half_angle (1, 1) sym
                opts.ant_spin_rate (1, 1) sym
                opts.ant_altitude (1, 1) sym
                opts.tx_freq (1, 1) sym
                opts.tx_power (1, 1) sym
                opts.tx_pulse_width (1, 1) sym
                opts.tx_prf (1, 1) sym
                opts.tx_pcr double
                opts.t_fa (1, 1) sym
                opts.scan_qty_on_tgt_intent (1, 1) uint32
            end

            u = symunit;

            if contains('simultaneous, sequential', rdr_mode_strategy) == 0
                error('Input argument "rdr_mode_strategy" must be one of "simultaneous" or "sequential".')
            end

            if checkUnits(opts.ant_bs_grazing_ang_mid == u.deg).Compatible == 0
                error('Input argument "ant_bs_grazing_ang_mid" must be in units of degrees.')
            elseif separateUnits(unitConvert(opts.ant_bs_grazing_ang_mid, u.deg)) <= 0 || ...
                    separateUnits(unitConvert(opts.ant_bs_grazing_ang_mid, u.deg)) > 90
                error('Input argument "ant_bs_grazing_ang_mid" must be between 0 and 90 degrees.')
            end

            if checkUnits(opts.ant_dim_elev == u.m).Compatible == 0
                error('Input argument "ant_dim_elev" must have units of distance.')
            elseif separateUnits(unitConvert(opts.ant_dim_elev, u.m)) <= 0 || ...
                    separateUnits(unitConvert(opts.ant_dim_elev, u.m)) > 1
                error('Input argument "ant_dim_elev" must have a value between 0 and 1 meters.')
            end

            if checkUnits(opts.ant_dim_azim == u.m).Compatible == 0
                error('Input argument "ant_dim_azim" must have units of distance.')
            elseif separateUnits(unitConvert(opts.ant_dim_azim, u.m)) <= 0 || ...
                    separateUnits(unitConvert(opts.ant_dim_azim, u.m)) > 1
                error('Input argument "ant_dim_azim" must have a value greater than 0 and 1 meters.')
            end

            if checkUnits(opts.ant_azim_fwd_look_half_angle == u.deg).Compatible == 0
                error('Input argument "ant_azim_fwd_look_half_angle" must be in units of degrees.')
                % WARNING: Directly entering const_fwd_look_half_ang_max value for upper bound check val
                %          because we can't reference it before the class object is instantiated!
                %          Update this value if const_fwd_look_half_ang_max ever changes!
            elseif separateUnits(unitConvert(opts.ant_azim_fwd_look_half_angle, u.deg)) <= 0 || ...
                    separateUnits(unitConvert(opts.ant_azim_fwd_look_half_angle, u.deg)) > 90
                error('Input argument "ant_azim_fwd_look_half_angle" must be between 0 and 90 degrees (total swath = 0-180 deg).')
            end

            if checkUnits(opts.ant_spin_rate == u.rpm).Compatible == 0
                error('Input argument "ant_spin_rate" must have units of revolutions per minute.')
                % WARNING: Directly entering values for upper/lower bound check val
                %          because we can't reference it before the class object is instantiated!
                %          Update this value if ant_spin_rate limits ever change!
            elseif separateUnits(unitConvert(opts.ant_spin_rate, u.rpm)) <= 0 || ...
                    separateUnits(unitConvert(opts.ant_spin_rate, u.rpm)) > 180
                error('Input argument "ant_spin_rate" must have a value between 0 and 180 rpm.')
            end

            if checkUnits(opts.ant_altitude == u.m).Compatible == 0
                error('Input argument "ant_altitude" must have units of meters.')
                % WARNING: Directly entering value for upper bound check val
                %          because we can't reference it before the class object is instantiated!
                %          Update this value if altitude constraints ever change!
            elseif separateUnits(unitConvert(opts.ant_altitude, u.km)) < 5 || ...
                    separateUnits(unitConvert(opts.ant_altitude, u.km)) > 15
                error('Input argument "ant_altitude" esceeds design limits.')
            end

            if checkUnits(opts.tx_freq == u.Hz).Compatible == 0
                error('Input argument "tx_freq" must have units of Hertz.')
                % WARNING: Directly entering value for set check vals
                %          because we can't reference it before the class object is instantiated!
                %          Update this value if freq constraints ever change!
            elseif ismember(separateUnits(unitConvert(opts.tx_freq, u.GHz)), [37, 90, 150]) == 0
                error('Input argument "tx_freq" must be one of 37, 90, or 150 GHz.')
            end

            if checkUnits(opts.tx_power == u.W).Compatible == 0
                error('Input argument "tx_power" must have units of Watts.')
            elseif separateUnits(unitConvert(opts.tx_power, u.W)) <= 0 || ...
                    separateUnits(unitConvert(opts.tx_power, u.W)) > 1000
                error('Input argument "tx_power" must have a value between 0 and 1000.')
            end

            if checkUnits(opts.tx_pulse_width == u.sec).Compatible == 0
                error('Input argument "tx_pulse_width" must have units of seconds.')
            elseif separateUnits(unitConvert(opts.tx_pulse_width, u.s)) <= 0
                error('Input argument "tx_pulse_width" must have a value greater than 0.')
            end

            if checkUnits(opts.tx_prf == u.Hz).Compatible == 0
                error('Input argument "tx_prf" must have units of Hertz.')
            elseif separateUnits(unitConvert(opts.tx_prf, u.Hz)) <= 0 || ...
                    separateUnits(unitConvert(opts.tx_prf, u.Hz)) > 500000
                error('Input argument "tx_prf" must have a value between 0 and 500k.')
            end

            % TODO: Ensure this validation check is correct
            if isUnit(opts.tx_pcr)
                error('Input argument "tx_pcr" must not be a symbolic unit.')
            elseif opts.tx_pcr < 0
                error('Input argument "tx_pcr" must have a value greater than 0.')
            end

            if checkUnits(opts.t_fa == u.sec).Compatible == 0
                error('Input argument "t_fa" must have units of seconds.')
            elseif separateUnits(unitConvert(opts.t_fa, u.sec)) <= 0
                error('Input argument "t_fa" must have a value greater than 0.')
            end

            if isUnit(opts.scan_qty_on_tgt_intent)
                error('Input argument "scan_qty_on_tgt_intent" must not be a symunit.')
            elseif mod(opts.scan_qty_on_tgt_intent, 1) ~= 0
                error('Input argument "scan_qty_on_tgt_intent" must be an interger value.')
            elseif opts.scan_qty_on_tgt_intent < 4
                error('Input argument "scan_qty_on_tgt_intent" must have a minimum value of 4.')
            end

            obj.rdr_mode_strategy = rdr_mode_strategy;
            obj.ant_bs_grazing_ang_mid = opts.ant_bs_grazing_ang_mid;
            obj.ant_dim_elev = opts.ant_dim_elev;
            obj.ant_dim_azim = opts.ant_dim_azim;
            obj.ant_azim_fwd_look_half_angle = opts.ant_azim_fwd_look_half_angle;
            obj.ant_spin_rate = opts.ant_spin_rate;
            obj.ant_altitude = opts.ant_altitude;
            obj.tx_freq = opts.tx_freq;
            obj.tx_power = opts.tx_power;
            obj.tx_pulse_width = opts.tx_pulse_width;
            obj.tx_prf = opts.tx_prf;
            obj.tx_pcr = opts.tx_pcr;
            obj.t_fa = opts.t_fa;
            obj.scan_qty_on_tgt_intent = opts.scan_qty_on_tgt_intent;
        end

        %% Property Set Functions

        function set.rdr_mode_strategy(obj, val)
            obj.rdr_mode_strategy = val;
            obj.purge_model_cache;
        end

        function set.ant_bs_grazing_ang_mid(obj, val)
            obj.ant_bs_grazing_ang_mid = val;
            obj.purge_model_cache;
        end

        function set.ant_dim_elev(obj, val)
            obj.ant_dim_elev = val;
            obj.purge_model_cache;
        end

        function set.ant_dim_azim(obj, val)
            obj.ant_dim_azim = val;
            obj.purge_model_cache;
        end

        function set.ant_azim_fwd_look_half_angle(obj, val)
            obj.ant_azim_fwd_look_half_angle = val;
            obj.purge_model_cache;
        end

        function set.ant_spin_rate(obj, val)
            obj.ant_spin_rate = val;
            obj.purge_model_cache;
        end

        function set.ant_altitude(obj, val)
            obj.ant_altitude = val;
            obj.purge_model_cache;
        end

        function set.tx_freq(obj, val)
            obj.tx_freq = val;
            obj.purge_model_cache;
        end

        function set.tx_power(obj, val)
            obj.tx_power = val;
            obj.purge_model_cache;
        end

        function set.tx_pulse_width(obj, val)
            obj.tx_pulse_width = val;
            obj.purge_model_cache;
        end

        function set.tx_prf(obj, val)
            obj.tx_prf = val;
            obj.purge_model_cache;
        end

        function set.tx_pcr(obj, val)
            obj.tx_pcr = val;
            obj.purge_model_cache;
        end

        function set.t_fa(obj, val)
            obj.t_fa = val;
            obj.purge_model_cache;
        end

        function set.scan_qty_on_tgt_intent(obj, val)
            obj.scan_qty_on_tgt_intent = val;
            obj.purge_model_cache;
        end

        %% Cache Management Functions

        function purge_model_cache(obj)
            % Purge cache
            cache_len = numEntries(obj.model_cache);

            if cache_len > 0
                cache_keys = keys(obj.model_cache);
                for i = 1:cache_len
                    % tmp_dict = remove(obj.model_cache, cache_keys(i));
                    % clearvars tmp_dict;
                    obj.model_cache = remove(obj.model_cache, cache_keys(i));
                end
            end
        end

        function val = dump_model_cache(obj)
            val = obj.model_cache;
        end

        %% Diagnostic Functions

        function val = dump_diagnostics(obj)
            u = symunit;
            diag_idx = 1;
            diag_out = cell(60, 3);

            [tmp_val, tmp_unit] = separateUnits(obj.bs_rng_near);
            diag_out(diag_idx, :) = {'Range BS - Near', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.bs_rng_mid);
            diag_out(diag_idx, :) = {'Range BS - Mid', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.bs_rng_far);
            diag_out(diag_idx, :) = {'Range BS - Far', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.pulse_rng_res_near);
            diag_out(diag_idx, :) = {'Pulse Range Rez - Near', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.pulse_rng_res_mid);
            diag_out(diag_idx, :) = {'Pulse Range Rez - Mid', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.pulse_rng_res_far);
            diag_out(diag_idx, :) = {'Pulse Range Rez - Far', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.pulse_azim_res_near);
            diag_out(diag_idx, :) = {'Pulse Azimuth Rez - Near', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.pulse_azim_res_mid);
            diag_out(diag_idx, :) = {'Pulse Azimuth Rez - Mid', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.pulse_azim_res_far);
            diag_out(diag_idx, :) = {'Pulse Azimuth Rez - Far', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.ifov_near);
            diag_out(diag_idx, :) = {'Pulse IFOV - Near', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.ifov_mid);
            diag_out(diag_idx, :) = {'Pulse IFOV - Mid', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.ifov_far);
            diag_out(diag_idx, :) = {'Pulse IFOV - Far', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.avg_tgt_xs_area_near);
            diag_out(diag_idx, :) = {'BS Tgt. Xsect. - Near', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.avg_tgt_xs_area_mid);
            diag_out(diag_idx, :) = {'BS Tgt. Xsect. - Mid', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.avg_tgt_xs_area_far);
            diag_out(diag_idx, :) = {'BS Tgt. Xsect. - Far', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.clutter_eff_area_near);
            diag_out(diag_idx, :) = {'Clutter Eff. Xsect. - Near', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.clutter_eff_area_mid);
            diag_out(diag_idx, :) = {'Clutter Eff. Xsect. - Mid', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.clutter_eff_area_far);
            diag_out(diag_idx, :) = {'Clutter Eff. Xsect. - Far', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'T/C - Near', double(obj.tgt_to_clutter_db_near), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'T/C - Mid', double(obj.tgt_to_clutter_db_mid), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'T/C - Far', double(obj.tgt_to_clutter_db_far), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'T/N - Near', double(obj.tgt_to_noise_db_near), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'T/N - Mid', double(obj.tgt_to_noise_db_mid), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'T/N - Far', double(obj.tgt_to_noise_db_far), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Cltr/N - Near', double(obj.clutter_to_noise_db_near), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Cltr/N - Mid', double(obj.clutter_to_noise_db_mid), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Cltr/N - Far', double(obj.clutter_to_noise_db_far), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'T/(C+N) - Near', double(obj.tgt_to_clutter_noise_db_near), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'T/(C+N) - Mid', double(obj.tgt_to_clutter_noise_db_mid), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'T/(C+N) - Far', double(obj.tgt_to_clutter_noise_db_far), 'dB'};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.time_on_target);
            diag_out(diag_idx, :) = {'TOT', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'POT', double(obj.pulses_on_target), 'pulses'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'P_det 1Look - Near', double(obj.p_det_multi_pulse_near), 'prob'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'P_det 1Look - Mid', double(obj.p_det_multi_pulse_mid), 'prob'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'P_det 1Look - Far', double(obj.p_det_multi_pulse_far), 'prob'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'P_det (2 of 4) - Near', double(obj.p_det_n_of_m_near), 'prob'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'P_det (2 of 4) - Mid', double(obj.p_det_n_of_m_mid), 'prob'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'P_det (2 of 4) - Far', double(obj.p_det_n_of_m_far), 'prob'};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.doppler_precision_near);
            diag_out(diag_idx, :) = {'Doppler Precision W/C - Near', tmp_val, symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.doppler_precision_mid);
            diag_out(diag_idx, :) = {'Doppler Precision W/C - Mid', tmp_val, symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.doppler_precision_far);
            diag_out(diag_idx, :) = {'Doppler Precision W/C - Far', tmp_val, symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.nyquist_reqd_for_max_doppler_near);
            diag_out(diag_idx, :) = {'Nyquist Reqd. for Doppler Max - Near', tmp_val, symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.nyquist_reqd_for_max_doppler_mid);
            diag_out(diag_idx, :) = {'Nyquist Reqd. for Doppler Max - Mid', tmp_val, symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.nyquist_reqd_for_max_doppler_far);
            diag_out(diag_idx, :) = {'Nyquist Reqd. for Doppler Max - Far', tmp_val, symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.fov_range, u.m));
            diag_out(diag_idx, :) = {'Ant. FP. Length', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Ant. Scan Overlap', obj.scan_fov_overlap_pct, 'pct'};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.ant_hpbw_elevation, u.deg));
            diag_out(diag_idx, :) = {'B_elev', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.ant_hpbw_azimuth, u.deg));
            diag_out(diag_idx, :) = {'B_azim', double(tmp_val), symunit2str(tmp_unit)};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Radar Xfactor - Near', double(obj.ratio2db(obj.rdr_xfactor_near)), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Radar Xfactor - Mid', double(obj.ratio2db(obj.rdr_xfactor_mid)), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Radar Xfactor - Far', double(obj.ratio2db(obj.rdr_xfactor_far)), 'dB'};

            val = diag_out;
        end

        function val = dump_eval_outputs(obj)
            u = symunit;
            eval_idx = 1;
            eval_out = cell(60, 3);

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.swath_width, u.km));
            eval_out(eval_idx, :) = {'Swath Width', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.tx_pulse_width, u.sec));
            eval_out(eval_idx, :) = {'[IN] Tx Pulse Width', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.ant_dim_elev, u.m));
            eval_out(eval_idx, :) = {'[IN] Ant Size Azimuth', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.ant_dim_azim, u.m));
            eval_out(eval_idx, :) = {'[IN] Ant. Size Elevation', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.ant_bs_grazing_ang_near, u.m));
            eval_out(eval_idx, :) = {'Min. Grazing Angle', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.ant_bs_grazing_ang_near, u.m));
            eval_out(eval_idx, :) = {'Min. Grazing Angle', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.max_prf_supported, u.Hz));
            eval_out(eval_idx, :) = {'Max PRF Supported', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.tx_prf, u.Hz));
            eval_out(eval_idx, :) = {'[IN] Selected PRF', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'T_spin / T_fa', obj.tfa_tspin_ratio, 'spins/fa'};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.ant_spin_rate, u.rpm));
            eval_out(eval_idx, :) = {'[IN] Ant. Spin Rate', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'[IN] Design Scan Qty. on Tgt.', obj.scan_qty_on_tgt_intent, 'scans'};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.min_spin_rate_supported, u.rpm));
            eval_out(eval_idx, :) = {'Min. Spin Rate Supported', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(unitConvert(obj.t_warn, u.sec));
            eval_out(eval_idx, :) = {'Worst Case T_warn', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.tx_duty_cycle);
            eval_out(eval_idx, :) = {'Tx Duty Cycle', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.pulse_rng_res_far);
            eval_out(eval_idx, :) = {'BS Range Resolution (far?)', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.pulse_azim_res_far);
            eval_out(eval_idx, :) = {'BS Azimuth Resolution (far?)', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.p_det_multi_pulse_near);
            eval_out(eval_idx, :) = {'P_det - Near', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.p_det_multi_pulse_mid);
            eval_out(eval_idx, :) = {'P_det - Mid', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.p_det_multi_pulse_far);
            eval_out(eval_idx, :) = {'P_det - Far', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.doppler_time_on_target);
            eval_out(eval_idx, :) = {'Doppler TOT (incl. design scan qty.)', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.worst_case_nyquist_reqd_for_max_doppler);
            eval_out(eval_idx, :) = {'Nyquist PRF for Doppler Meas.', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.worst_case_max_expected_doppler_freq);
            eval_out(eval_idx, :) = {'Max Reqd. Doppler Freq.', double(tmp_val), symunit2str(tmp_unit)};
            eval_idx = eval_idx + 1;

            [tmp_val, tmp_unit] = separateUnits(obj.worst_case_doppler_precision);
            eval_out(eval_idx, :) = {'Worst Case Doppler Precision', double(tmp_val), symunit2str(tmp_unit)};
            % eval_idx = eval_idx + 1;

            val = eval_out;
        end

        %% Dependent Property Functions

        function val = get.tx_duty_cycle(obj)
            if isKey(obj.model_cache, 'tx_duty_cycle')
                val = obj.model_cache('tx_duty_cycle');
            else
                u = symunit;
                ipp = 1 / unitConvert(obj.tx_prf, u.s);
                func_result = obj.tx_pulse_width / ipp;

                obj.model_cache('tx_duty_cycle') = vpa(simplify(func_result));
                val = obj.model_cache('tx_duty_cycle');
            end
        end

        function val = get.swath_width(obj)
            if isKey(obj.model_cache, 'swath_width')
                val = obj.model_cache('swath_width');
            else
                u = symunit;
                
                warning('Using FAR range/grz_ang values instead of NEAR. DrJ eval sheet appears to use FAR. Need to confirm this.')

                gnd_trk_rng_far = obj.bs_rng_far * separateUnits(unitConvert(obj.ant_bs_grazing_ang_far, u.rad));
                func_result = 2 * (gnd_trk_rng_far * sin(unitConvert(obj.ant_azim_fwd_look_half_angle, u.rad)));

                obj.model_cache('swath_width') = vpa(simplify(func_result));
                val = obj.model_cache('swath_width');
            end
        end

        function val = get.bs_rng_far(obj)
            if isKey(obj.model_cache, 'bs_rng_far')
                val = obj.model_cache('bs_rng_far');
            else
                u = symunit;
                inclination_ang_far = 90 * u.deg - obj.ant_bs_grazing_ang_far;
                func_result = obj.ant_altitude / cos(unitConvert(inclination_ang_far, u.rad));

                obj.model_cache('bs_rng_far') = vpa(simplify(func_result));
                val = obj.model_cache('bs_rng_far');
            end
        end

        function val = get.bs_rng_near(obj)
            if isKey(obj.model_cache, 'bs_rng_near')
                val = obj.model_cache('bs_rng_near');
            else
                u = symunit;
                inclination_ang_near = 90 * u.deg - obj.ant_bs_grazing_ang_near;
                func_result = obj.ant_altitude / cos(unitConvert(inclination_ang_near, u.rad));

                obj.model_cache('bs_rng_near') = vpa(simplify(func_result));
                val = obj.model_cache('bs_rng_near');
            end
        end

        function val = get.bs_rng_mid(obj)
            if isKey(obj.model_cache, 'bs_rng_mid')
                val = obj.model_cache('bs_rng_mid');
            else
                u = symunit;
                inclination_ang_mid = 90 * u.deg - obj.ant_bs_grazing_ang_mid;
                func_result = obj.ant_altitude / cos(unitConvert(inclination_ang_mid, u.rad));

                obj.model_cache('bs_rng_mid') = vpa(simplify(func_result));
                val = obj.model_cache('bs_rng_mid');
            end
        end

        function val = get.fov_range(obj)
            if isKey(obj.model_cache, 'fov_range')
                val = obj.model_cache('fov_range');
            else
                u = symunit;

                gnd_trk_rng_far = obj.bs_rng_far * cos(unitConvert(obj.ant_bs_grazing_ang_far, u.rad));
                gnd_trk_rng_near = obj.bs_rng_near * cos(unitConvert(obj.ant_bs_grazing_ang_near, u.rad));

                func_result = gnd_trk_rng_far - gnd_trk_rng_near;

                obj.model_cache('fov_range') = vpa(simplify(func_result));
                val = obj.model_cache('fov_range');
            end
        end

        function val = get.fov_azimuth(obj)
            % NB: We just call pulse_azim_res_mid() here since it acts as the "most average" value
            %     If you're looking for possible depndent calculation issues, we probably need to provide
            %     azimuth FOV for near & far as well.
            val = obj.pulse_azim_res_mid;
        end

        function val = get.fov_area_approx(obj)
            if isKey(obj.model_cache, 'fov_area_approx')
                val = obj.model_cache('fov_area_approx');
            else
                func_result = obj.fov_range * obj.fov_azimuth;

                obj.model_cache('fov_area_approx') = vpa(simplify(func_result));
                val = obj.model_cache('fov_area_approx');
            end
        end

        function val = get.t_spin(obj)
            if isKey(obj.model_cache, 't_spin')
                val = obj.model_cache('t_spin');
            else
                u = symunit;
                func_result = 60 / separateUnits(unitConvert(obj.ant_spin_rate, u.rpm)) * u.sec;

                obj.model_cache('t_spin') = vpa(simplify(func_result));
                val = obj.model_cache('t_spin');
            end
        end

        function val = get.tfa_tspin_ratio(obj)
            if isKey(obj.model_cache, 'tfa_tspin_ratio')
                val = obj.model_cache('tfa_tspin_ratio');
            else
                func_result = obj.t_fa / obj.t_spin;

                obj.model_cache('tfa_tspin_ratio') = vpa(simplify(func_result));
                val = obj.model_cache('tfa_tspin_ratio');
            end
        end

        function val = get.p_fa(obj)
            if isKey(obj.model_cache, 'p_fa')
                val = obj.model_cache('p_fa');
            else
                func_result = 1 / (obj.t_fa * obj.rx_minus3dB_bw_predet);

                obj.model_cache('p_fa') = vpa(simplify(func_result));
                val = obj.model_cache('p_fa');
            end
        end

        function val = get.rdr_xfactor_near(obj)
            if isKey(obj.model_cache, 'rdr_xfactor_near')
                val = obj.model_cache('rdr_xfactor_near');
            else
                % NB: For this model, the only Lsys component being considered is Latm_roundtrip
                local_lsys_db = obj.l_atm_roundtrip_db_near;

                func_result = obj.tx_power * ...
                    (obj.tx_ant_gain) ^ 2 * ...
                    (obj.freq2wavelen(obj.tx_freq) ^ 2) * ...
                    (1 / ((4 * pi) ^ 3)) * ...
                    obj.db2ratio(local_lsys_db);

                obj.model_cache('rdr_xfactor_near') = vpa(simplify(func_result));
                val = obj.model_cache('rdr_xfactor_near');
            end
        end

        function val = get.rdr_xfactor_mid(obj)
            if isKey(obj.model_cache, 'rdr_xfactor_mid')
                val = obj.model_cache('rdr_xfactor_mid');
            else
                % NB: For this model, the only Lsys component being considered is Latm_roundtrip
                local_lsys_db = obj.l_atm_roundtrip_db_mid;

                func_result = obj.tx_power * ...
                    (obj.tx_ant_gain) ^ 2 * ...
                    (obj.freq2wavelen(obj.tx_freq) ^ 2) * ...
                    (1 / ((4 * pi) ^ 3)) * ...
                    obj.db2ratio(local_lsys_db);

                obj.model_cache('rdr_xfactor_mid') = vpa(simplify(func_result));
                val = obj.model_cache('rdr_xfactor_mid');
            end
        end

        function val = get.rdr_xfactor_far(obj)
            if isKey(obj.model_cache, 'rdr_xfactor_far')
                val = obj.model_cache('rdr_xfactor_far');
            else
                % NB: For this model, the only Lsys component being considered is Latm_roundtrip
                local_lsys_db = obj.l_atm_roundtrip_db_far;

                func_result = obj.tx_power * ...
                    (obj.tx_ant_gain) ^ 2 * ...
                    (obj.freq2wavelen(obj.tx_freq) ^ 2) * ...
                    (1 / ((4 * pi) ^ 3)) * ...
                    obj.db2ratio(local_lsys_db);

                obj.model_cache('rdr_xfactor_far') = vpa(simplify(func_result));
                val = obj.model_cache('rdr_xfactor_far');
            end
        end

        function val = get.rx_single_pulse_pwr_near(obj)
            if isKey(obj.model_cache, 'rx_single_pulse_pwr_near')
                val = obj.model_cache('rx_single_pulse_pwr_near');
            else
                func_result = obj.rdr_xfactor_near * (obj.avg_tgt_xs_area_near / (obj.bs_rng_near ^ 4));

                obj.model_cache('rx_single_pulse_pwr_near') = vpa(simplify(func_result));
                val = obj.model_cache('rx_single_pulse_pwr_near');
            end
        end

        function val = get.rx_single_pulse_pwr_mid(obj)
            if isKey(obj.model_cache, 'rx_single_pulse_pwr_mid')
                val = obj.model_cache('rx_single_pulse_pwr_mid');
            else
                func_result = obj.rdr_xfactor_mid * (obj.avg_tgt_xs_area_mid / (obj.bs_rng_mid ^ 4));

                obj.model_cache('rx_single_pulse_pwr_mid') = vpa(simplify(func_result));
                val = obj.model_cache('rx_single_pulse_pwr_mid');
            end
        end

        function val = get.rx_single_pulse_pwr_far(obj)
            if isKey(obj.model_cache, 'rx_single_pulse_pwr_far')
                val = obj.model_cache('rx_single_pulse_pwr_far');
            else
                func_result = obj.rdr_xfactor_far * (obj.avg_tgt_xs_area_far / (obj.bs_rng_far ^ 4));

                obj.model_cache('rx_single_pulse_pwr_far') = vpa(simplify(func_result));
                val = obj.model_cache('rx_single_pulse_pwr_far');
            end
        end

        function val = get.rx_single_pulse_pwr_db_near(obj)
            val = obj.ratio2db(obj.rx_single_pulse_pwr_near);
        end

        function val = get.rx_single_pulse_pwr_db_mid(obj)
            val = obj.ratio2db(obj.rx_single_pulse_pwr_mid);
        end

        function val = get.rx_single_pulse_pwr_db_far(obj)
            val = obj.ratio2db(obj.rx_single_pulse_pwr_far);
        end

        function val = get.rx_noise_power(obj)
            if isKey(obj.model_cache, 'rx_noise_power')
                val = obj.model_cache('rx_noise_power');
            else
                u = symunit;
                func_result = unitConvert(unitConvert(u.k_B, u.J / u.K) * obj.t_sys * unitConvert(obj.rx_minus3dB_bw_predet, 1 / u.s), u.W);

                obj.model_cache('rx_noise_power') = vpa(simplify(func_result));
                val = obj.model_cache('rx_noise_power');
            end
        end

        function val = get.rx_noise_power_db(obj)
            val = obj.ratio2db(obj.rx_noise_power);
        end

        function val = get.clutter_sigma0_db_near(obj)
            if isKey(obj.model_cache, 'clutter_sigma0_db_near')
                val = obj.model_cache('clutter_sigma0_db_near');
            else
                u = symunit;
                grz_angle_deg = double(separateUnits(unitConvert(obj.ant_bs_grazing_ang_near, u.deg)));
                func_result = ((obj.const_clut_p1 * grz_angle_deg ^ 4) + (obj.const_clut_p2 * grz_angle_deg ^ 3) + ...
                    (obj.const_clut_p3 * grz_angle_deg ^ 2) + (obj.const_clut_p4 * grz_angle_deg) + obj.const_clut_p5);

                obj.model_cache('clutter_sigma0_db_near') = func_result;
                val = obj.model_cache('clutter_sigma0_db_near');
            end
        end

        function val = get.clutter_sigma0_db_mid(obj)
            if isKey(obj.model_cache, 'clutter_sigma0_db_mid')
                val = obj.model_cache('clutter_sigma0_db_mid');
            else
                u = symunit;
                grz_angle_deg = double(separateUnits(unitConvert(obj.ant_bs_grazing_ang_mid, u.deg)));
                func_result = ((obj.const_clut_p1 * grz_angle_deg ^ 4) + (obj.const_clut_p2 * grz_angle_deg ^ 3) + ...
                    (obj.const_clut_p3 * grz_angle_deg ^ 2) + (obj.const_clut_p4 * grz_angle_deg) + obj.const_clut_p5);

                obj.model_cache('clutter_sigma0_db_mid') = func_result;
                val = obj.model_cache('clutter_sigma0_db_mid');
            end
        end

        function val = get.clutter_sigma0_db_far(obj)
            if isKey(obj.model_cache, 'clutter_sigma0_db_far')
                val = obj.model_cache('clutter_sigma0_db_far');
            else
                u = symunit;
                grz_angle_deg = double(separateUnits(unitConvert(obj.ant_bs_grazing_ang_far, u.deg)));
                func_result = ((obj.const_clut_p1 * grz_angle_deg ^ 4) + (obj.const_clut_p2 * grz_angle_deg ^ 3) + ...
                    (obj.const_clut_p3 * grz_angle_deg ^ 2) + (obj.const_clut_p4 * grz_angle_deg) + obj.const_clut_p5);

                obj.model_cache('clutter_sigma0_db_far') = func_result;
                val = obj.model_cache('clutter_sigma0_db_far');
            end
        end

        function val = get.clutter_eff_area_near(obj)
            if isKey(obj.model_cache, 'clutter_eff_area_near')
                val = obj.model_cache('clutter_eff_area_near');
            else
                u = symunit;

                func_result = obj.db2ratio(obj.clutter_sigma0_db_near) * unitConvert(obj.ifov_near, u.m ^ 2);

                obj.model_cache('clutter_eff_area_near') = vpa(simplify(func_result));
                val = obj.model_cache('clutter_eff_area_near');
            end
        end

        function val = get.clutter_eff_area_mid(obj)
            if isKey(obj.model_cache, 'clutter_eff_area_mid')
                val = obj.model_cache('clutter_eff_area_mid');
            else
                u = symunit;

                func_result = obj.db2ratio(obj.clutter_sigma0_db_mid) * unitConvert(obj.ifov_mid, u.m ^ 2);

                obj.model_cache('clutter_eff_area_mid') = vpa(simplify(func_result));
                val = obj.model_cache('clutter_eff_area_mid');
            end
        end

        function val = get.clutter_eff_area_far(obj)
            if isKey(obj.model_cache, 'clutter_eff_area_far')
                val = obj.model_cache('clutter_eff_area_far');
            else
                u = symunit;

                func_result = obj.db2ratio(obj.clutter_sigma0_db_far) * unitConvert(obj.ifov_far, u.m ^ 2);

                obj.model_cache('clutter_eff_area_far') = vpa(simplify(func_result));
                val = obj.model_cache('clutter_eff_area_far');
            end
        end

        % function val = get.rx_clutter_pwr_db_near(obj)
        %     if isKey(obj.model_cache, 'rx_clutter_pwr_db_near')
        %         val = obj.model_cache('rx_clutter_pwr_db_near');
        %     else
        %         func_result = obj.clutter_to_noise_db_near + obj.rx_noise_power_db;
        %         obj.model_cache('rx_clutter_pwr_db_near') = func_result;
        %         val = func_result;
        %     end
        % end

        % function val = get.rx_clutter_pwr_db_mid(obj)
        %     if isKey(obj.model_cache, 'rx_clutter_pwr_db_mid')
        %         val = obj.model_cache('rx_clutter_pwr_db_mid');
        %     else
        %         func_result = obj.clutter_to_noise_db_mid + obj.rx_noise_power_db;
        %         obj.model_cache('rx_clutter_pwr_db_mid') = func_result;
        %         val = func_result;
        %     end
        % end

        % function val = get.rx_clutter_pwr_db_far(obj)
        %     if isKey(obj.model_cache, 'rx_clutter_pwr_db_far')
        %         val = obj.model_cache('rx_clutter_pwr_db_far');
        %     else
        %         func_result = obj.clutter_to_noise_db_far + obj.rx_noise_power_db;
        %         obj.model_cache('rx_clutter_pwr_db_far') = func_result;
        %         val = func_result;
        %     end
        % end

        function val = get.tgt_to_clutter_db_near(obj)
            if isKey(obj.model_cache, 'tgt_to_clutter_db_near')
                val = obj.model_cache('tgt_to_clutter_db_near');
            else
                func_result = obj.ratio2db(obj.avg_tgt_xs_area_near / obj.clutter_eff_area_near);
                obj.model_cache('tgt_to_clutter_db_near') = vpa(simplify(func_result));
                val = obj.model_cache('tgt_to_clutter_db_near');
            end
        end

        function val = get.tgt_to_clutter_db_mid(obj)
            if isKey(obj.model_cache, 'tgt_to_clutter_db_mid')
                val = obj.model_cache('tgt_to_clutter_db_mid');
            else
                func_result = obj.ratio2db(obj.avg_tgt_xs_area_mid / obj.clutter_eff_area_mid);
                obj.model_cache('tgt_to_clutter_db_mid') = vpa(simplify(func_result));
                val = obj.model_cache('tgt_to_clutter_db_mid');
            end
        end

        function val = get.tgt_to_clutter_db_far(obj)
            if isKey(obj.model_cache, 'tgt_to_clutter_db_far')
                val = obj.model_cache('tgt_to_clutter_db_far');
            else
                func_result = obj.ratio2db(obj.avg_tgt_xs_area_far / obj.clutter_eff_area_far);
                obj.model_cache('tgt_to_clutter_db_far') = vpa(simplify(func_result));
                val = obj.model_cache('tgt_to_clutter_db_far');
            end
        end

        function val = get.tgt_to_noise_db_near(obj)
            if isKey(obj.model_cache, 'tgt_to_noise_db_near')
                val = obj.model_cache('tgt_to_noise_db_near');
            else
                func_result = obj.rx_single_pulse_pwr_db_near - obj.rx_noise_power_db;
                obj.model_cache('tgt_to_noise_db_near') = vpa(simplify(func_result));
                val = obj.model_cache('tgt_to_noise_db_near');
            end
        end

        function val = get.tgt_to_noise_db_mid(obj)
            if isKey(obj.model_cache, 'tgt_to_noise_db_mid')
                val = obj.model_cache('tgt_to_noise_db_mid');
            else
                func_result = obj.rx_single_pulse_pwr_db_mid - obj.rx_noise_power_db;
                obj.model_cache('tgt_to_noise_db_mid') = vpa(simplify(func_result));
                val = obj.model_cache('tgt_to_noise_db_mid');
            end
        end

        function val = get.tgt_to_noise_db_far(obj)
            if isKey(obj.model_cache, 'tgt_to_noise_db_far')
                val = obj.model_cache('tgt_to_noise_db_far');
            else
                func_result = obj.rx_single_pulse_pwr_db_far - obj.rx_noise_power_db;
                obj.model_cache('tgt_to_noise_db_far') = vpa(simplify(func_result));
                val = obj.model_cache('tgt_to_noise_db_far');
            end
        end

        function val = get.clutter_to_noise_db_near(obj)
            if isKey(obj.model_cache, 'clutter_to_noise_db_near')
                val = obj.model_cache('clutter_to_noise_db_near');
            else
                clutter_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_clutter_db_near);
                clutter_to_noise_ratio = clutter_to_tgt_ratio * obj.db2ratio(obj.tgt_to_noise_db_near);
                func_result = obj.ratio2db(clutter_to_noise_ratio);

                obj.model_cache('clutter_to_noise_db_near') = vpa(simplify(func_result));
                val = obj.model_cache('clutter_to_noise_db_near');
            end
        end

        function val = get.clutter_to_noise_db_mid(obj)
            if isKey(obj.model_cache, 'clutter_to_noise_db_mid')
                val = obj.model_cache('clutter_to_noise_db_mid');
            else
                clutter_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_clutter_db_mid);
                clutter_to_noise_ratio = clutter_to_tgt_ratio * obj.db2ratio(obj.tgt_to_noise_db_mid);
                func_result = obj.ratio2db(clutter_to_noise_ratio);

                obj.model_cache('clutter_to_noise_db_mid') = vpa(simplify(func_result));
                val = obj.model_cache('clutter_to_noise_db_mid');
            end
        end

        function val = get.clutter_to_noise_db_far(obj)
            if isKey(obj.model_cache, 'clutter_to_noise_db_far')
                val = obj.model_cache('clutter_to_noise_db_far');
            else
                clutter_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_clutter_db_far);
                clutter_to_noise_ratio = clutter_to_tgt_ratio * obj.db2ratio(obj.tgt_to_noise_db_far);
                func_result = obj.ratio2db(clutter_to_noise_ratio);

                obj.model_cache('clutter_to_noise_db_far') = vpa(simplify(func_result));
                val = obj.model_cache('clutter_to_noise_db_far');
            end
        end

        function val = get.tgt_to_clutter_noise_db_near(obj)
            if isKey(obj.model_cache, 'tgt_to_clutter_noise_db_near')
                val = obj.model_cache('tgt_to_clutter_noise_db_near');
            else
                clutter_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_clutter_db_near);
                noise_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_noise_db_near);

                clutter_noise_to_tgt_ratio = clutter_to_tgt_ratio + noise_to_tgt_ratio;

                tgt_to_clutter_noise_ratio = 1 / clutter_noise_to_tgt_ratio;

                func_result = obj.ratio2db(tgt_to_clutter_noise_ratio);

                obj.model_cache('tgt_to_clutter_noise_db_near') = vpa(simplify(func_result));
                val = obj.model_cache('tgt_to_clutter_noise_db_near');
            end
        end

        function val = get.tgt_to_clutter_noise_db_mid(obj)
            if isKey(obj.model_cache, 'tgt_to_clutter_noise_db_mid')
                val = obj.model_cache('tgt_to_clutter_noise_db_mid');
            else
                clutter_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_clutter_db_mid);
                noise_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_noise_db_mid);

                clutter_noise_to_tgt_ratio = clutter_to_tgt_ratio + noise_to_tgt_ratio;

                tgt_to_clutter_noise_ratio = 1 / clutter_noise_to_tgt_ratio;

                func_result = obj.ratio2db(tgt_to_clutter_noise_ratio);

                obj.model_cache('tgt_to_clutter_noise_db_mid') = vpa(simplify(func_result));
                val = obj.model_cache('tgt_to_clutter_noise_db_mid');
            end
        end

        function val = get.tgt_to_clutter_noise_db_far(obj)
            if isKey(obj.model_cache, 'tgt_to_clutter_noise_db_far')
                val = obj.model_cache('tgt_to_clutter_noise_db_far');
            else
                clutter_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_clutter_db_far);
                noise_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_noise_db_far);

                clutter_noise_to_tgt_ratio = clutter_to_tgt_ratio + noise_to_tgt_ratio;

                tgt_to_clutter_noise_ratio = 1 / clutter_noise_to_tgt_ratio;

                func_result = obj.ratio2db(tgt_to_clutter_noise_ratio);

                obj.model_cache('tgt_to_clutter_noise_db_far') = vpa(simplify(func_result));
                val = obj.model_cache('tgt_to_clutter_noise_db_far');
            end
        end

        function val = get.p_det_single_pulse_near(obj)
            if isKey(obj.model_cache, 'p_det_single_pulse_near')
                val = obj.model_cache('p_det_single_pulse_near');
            else
                syms p_det;
                a_factor = log(0.62 / obj.p_fa);
                b_factor = log(p_det / (1 - p_det));

                eqn_near = obj.db2ratio(obj.tgt_to_clutter_noise_db_near) == a_factor + (0.12 * a_factor * b_factor) + (1.7 * b_factor);

                func_result = simplify(solve(eqn_near, p_det));

                if func_result < 0 && func_result > 1
                    error('Calculation result for one or more values are out of bounds.')
                end

                obj.model_cache('p_det_single_pulse_near') = vpa(simplify(func_result));
                val = obj.model_cache('p_det_single_pulse_near');
            end
        end

        function val = get.p_det_single_pulse_mid(obj)
            if isKey(obj.model_cache, 'p_det_single_pulse_mid')
                val = obj.model_cache('p_det_single_pulse_mid');
            else
                syms p_det;
                a_factor = log(0.62 / obj.p_fa);
                b_factor = log(p_det / (1 - p_det));

                eqn_near = obj.db2ratio(obj.tgt_to_clutter_noise_db_mid) == a_factor + (0.12 * a_factor * b_factor) + (1.7 * b_factor);

                func_result = simplify(solve(eqn_near, p_det));

                if func_result < 0 && func_result > 1
                    error('Calculation result for one or more values are out of bounds.')
                end

                obj.model_cache('p_det_single_pulse_mid') = vpa(simplify(func_result));
                val = obj.model_cache('p_det_single_pulse_mid');
            end
        end

        function val = get.p_det_single_pulse_far(obj)
            if isKey(obj.model_cache, 'p_det_single_pulse_far')
                val = obj.model_cache('p_det_single_pulse_far');
            else
                syms p_det;
                a_factor = log(0.62 / obj.p_fa);
                b_factor = log(p_det / (1 - p_det));

                eqn_near = obj.db2ratio(obj.tgt_to_clutter_noise_db_far) == a_factor + (0.12 * a_factor * b_factor) + (1.7 * b_factor);

                func_result = simplify(solve(eqn_near, p_det));

                if func_result < 0 && func_result > 1
                    error('Calculation result for one or more values are out of bounds.')
                end

                obj.model_cache('p_det_single_pulse_far') = vpa(simplify(func_result));
                val = obj.model_cache('p_det_single_pulse_far');
            end
        end

        function val = get.p_det_multi_pulse_near(obj)
            if isKey(obj.model_cache, 'p_det_multi_pulse_near')
                val = obj.model_cache('p_det_multi_pulse_near');
            else
                % Ref: '03_L-3B Radar_pulse_integ_POMR-revW_web.pdf' slide 62
                a_factor = vpa(simplify(log(0.62 / obj.p_fa)));
                epsilon_factor = vpa(1 / (0.62 + (0.454 / sqrt(obj.pulses_on_target + 0.44))));
                chi_factor = vpa((obj.db2ratio(obj.tgt_to_clutter_noise_db_near) * sqrt(obj.pulses_on_target)) ^ epsilon_factor);
                beta_factor = (chi_factor - a_factor) / (0.12 * a_factor + 1.7);

                func_result = vpa(exp(beta_factor) / (1 + exp(beta_factor)));

                obj.model_cache('p_det_multi_pulse_near') = vpa(simplify(func_result));
                val = obj.model_cache('p_det_multi_pulse_near');
            end
        end

        function val = get.p_det_multi_pulse_mid(obj)
            if isKey(obj.model_cache, 'p_det_multi_pulse_mid')
                val = obj.model_cache('p_det_multi_pulse_mid');
            else
                % Ref: '03_L-3B Radar_pulse_integ_POMR-revW_web.pdf' slide 62
                a_factor = vpa(simplify(log(0.62 / obj.p_fa)));
                epsilon_factor = vpa(1 / (0.62 + (0.454 / sqrt(obj.pulses_on_target + 0.44))));
                chi_factor = vpa((obj.db2ratio(obj.tgt_to_clutter_noise_db_mid) * sqrt(obj.pulses_on_target)) ^ epsilon_factor);
                beta_factor = (chi_factor - a_factor) / (0.12 * a_factor + 1.7);

                func_result = vpa(exp(beta_factor) / (1 + exp(beta_factor)));

                obj.model_cache('p_det_multi_pulse_mid') = vpa(simplify(func_result));
                val = obj.model_cache('p_det_multi_pulse_mid');
            end
        end

        function val = get.p_det_multi_pulse_far(obj)
            if isKey(obj.model_cache, 'p_det_multi_pulse_far')
                val = obj.model_cache('p_det_multi_pulse_far');
            else
                % Ref: '03_L-3B Radar_pulse_integ_POMR-revW_web.pdf' slide 62
                a_factor = vpa(simplify(log(0.62 / obj.p_fa)));
                epsilon_factor = vpa(1 / (0.62 + (0.454 / sqrt(obj.pulses_on_target + 0.44))));
                chi_factor = vpa((obj.db2ratio(obj.tgt_to_clutter_noise_db_far) * sqrt(obj.pulses_on_target)) ^ epsilon_factor);
                beta_factor = (chi_factor - a_factor) / (0.12 * a_factor + 1.7);

                func_result = vpa(exp(beta_factor) / (1 + exp(beta_factor)));

                obj.model_cache('p_det_multi_pulse_far') = vpa(simplify(func_result));
                val = obj.model_cache('p_det_multi_pulse_far');
            end
        end

        function val = get.worst_case_p_det_multi_pulse(obj)
            val = min([obj.p_det_multi_pulse_near, ...
                           obj.p_det_multi_pulse_mid, ...
                           obj.p_det_multi_pulse_far]);
        end

        function val = get.tgt_to_clutter_noise_noncoh_multi_db_near(obj)
            if isKey(obj.model_cache, 't2cn_noncoh_multi_db_near')
                val = obj.model_cache('t2cn_noncoh_multi_db_near');
            else
                func_result = obj.db2ratio((-5 * log10(obj.pulses_on_target)) + ...
                    (6.2 + (4.54 / sqrt(obj.pulses_on_target + 0.44))) * ...
                    (log10(obj.p_det_single_pulse_near)));

                obj.model_cache('t2cn_noncoh_multi_db_near') = vpa(simplify(func_result));
                val = obj.model_cache('t2cn_noncoh_multi_db_near');
            end
        end

        function val = get.tgt_to_clutter_noise_noncoh_multi_db_mid(obj)
            if isKey(obj.model_cache, 't2cn_noncoh_multi_db_mid')
                val = obj.model_cache('t2cn_noncoh_multi_db_mid');
            else
                func_result = obj.db2ratio((-5 * log10(obj.pulses_on_target)) + ...
                    (6.2 + (4.54 / sqrt(obj.pulses_on_target + 0.44))) * ...
                    (log10(obj.p_det_single_pulse_mid)));

                obj.model_cache('t2cn_noncoh_multi_db_mid') = vpa(simplify(func_result));
                val = obj.model_cache('t2cn_noncoh_multi_db_mid');
            end
        end

        function val = get.tgt_to_clutter_noise_noncoh_multi_db_far(obj)
            if isKey(obj.model_cache, 't2cn_noncoh_multi_db_far')
                val = obj.model_cache('t2cn_noncoh_multi_db_far');
            else
                func_result = obj.db2ratio((-5 * log10(obj.pulses_on_target)) + ...
                    (6.2 + (4.54 / sqrt(obj.pulses_on_target + 0.44))) * ...
                    (log10(obj.p_det_single_pulse_far)));

                obj.model_cache('t2cn_noncoh_multi_db_far') = vpa(simplify(func_result));
                val = obj.model_cache('t2cn_noncoh_multi_db_far');
            end
        end

        function val = get.p_det_n_of_m_near(obj)
            if isKey(obj.model_cache, 'p_det_n_of_m_near')
                val = obj.model_cache('p_det_n_of_m_near');
            else
                % NB: Since Binomial CDF == probability of AT MOST M successes of N trials, but we really want
                %     AT LEAST M successes of N trials, by applying -1 to scan_det we get the prob. of successes
                %     in AT MOST scan_tot-1 trials. Subtracting the CDF result from 1, we get the prob of
                %     detection for scan_det trials OR MORE in N trials (i.e. we find the target in scan_det trials or better).

                func_result = 1 - binocdf(max([0, obj.const_nofm_det_qty - 1]), obj.const_nofm_total_qty, obj.p_det_multi_pulse_near);

                obj.model_cache('p_det_n_of_m_near') = vpa(simplify(func_result));
                val = obj.model_cache('p_det_n_of_m_near');
            end
        end

        function val = get.p_det_n_of_m_mid(obj)
            if isKey(obj.model_cache, 'p_det_n_of_m_mid')
                val = obj.model_cache('p_det_n_of_m_mid');
            else
                % NB: Since Binomial CDF == probability of AT MOST M successes of N trials, but we really want
                %     AT LEAST M successes of N trials, by applying -1 to scan_det we get the prob. of successes
                %     in AT MOST scan_tot-1 trials. Subtracting the CDF result from 1, we get the prob of
                %     detection for scan_det trials OR MORE in N trials (i.e. we find the target in scan_det trials or better).

                func_result = 1 - binocdf(max([0, obj.const_nofm_det_qty - 1]), obj.const_nofm_total_qty, obj.p_det_multi_pulse_mid);

                obj.model_cache('p_det_n_of_m_mid') = vpa(simplify(func_result));
                val = obj.model_cache('p_det_n_of_m_mid');
            end
        end

        function val = get.p_det_n_of_m_far(obj)
            if isKey(obj.model_cache, 'p_det_n_of_m_far')
                val = obj.model_cache('p_det_n_of_m_far');
            else
                % NB: Since Binomial CDF == probability of AT MOST M successes of N trials, but we really want
                %     AT LEAST M successes of N trials, by applying -1 to scan_det we get the prob. of successes
                %     in AT MOST scan_tot-1 trials. Subtracting the CDF result from 1, we get the prob of
                %     detection for scan_det trials OR MORE in N trials (i.e. we find the target in scan_det trials or better).

                func_result = 1 - binocdf(max([0, obj.const_nofm_det_qty - 1]), obj.const_nofm_total_qty, obj.p_det_multi_pulse_far);

                obj.model_cache('p_det_n_of_m_far') = vpa(simplify(func_result));
                val = obj.model_cache('p_det_n_of_m_far');
            end
        end

        function val = get.t_warn(obj)
            warning('DrJ 20240312 Eval returned a T_warn of 0.0sec. Need more input checks to confirm validity of this function.')
            if isKey(obj.model_cache, 't_warn')
                val = obj.model_cache('t_warn');
            else
                u = symunit;

                gnd_trk_rng_near = obj.bs_rng_near * cos(unitConvert(obj.ant_bs_grazing_ang_near, u.rad));
                tot_rel_speed = obj.const_tgt_speed_max + obj.const_ac_gnd_speed;

                func_result = unitConvert(simplify(gnd_trk_rng_near / tot_rel_speed), u.sec);

                obj.model_cache('t_warn') = vpa(simplify(func_result));
                val = obj.model_cache('t_warn');
            end
        end

        function val = get.doppler_precision_near(obj)
            if isKey(obj.model_cache, 'doppler_precision_near')
                val = obj.model_cache('doppler_precision_near');
            else
                u = symunit;

                tau = unitConvert(obj.tx_pulse_width, u.sec);
                n_0 = unitConvert(unitConvert(u.k_B, u.J / u.K) * obj.t_sys, (u.W / u.K));
                tot_incl_all_scans_on_tgt = (obj.scan_qty_on_tgt_intent * (obj.pulses_on_target - 1)) / obj.tx_prf;

                func_result = unitConvert(1 / (tot_incl_all_scans_on_tgt * sqrt(2 * ((obj.db2ratio(obj.rx_single_pulse_pwr_db_near) * u.W) * tau) / n_0)), u.Hz);

                obj.model_cache('doppler_precision_near') = vpa(simplify(func_result));
                val = obj.model_cache('doppler_precision_near');
            end
        end

        function val = get.doppler_precision_mid(obj)
            if isKey(obj.model_cache, 'doppler_precision_mid')
                val = obj.model_cache('doppler_precision_mid');
            else
                u = symunit;

                tau = unitConvert(obj.tx_pulse_width, u.sec);
                n_0 = unitConvert(unitConvert(u.k_B, u.J / u.K) * obj.t_sys, (u.W / u.K));
                tot_incl_all_scans_on_tgt = (obj.scan_qty_on_tgt_intent * (obj.pulses_on_target - 1)) / obj.tx_prf;

                func_result = unitConvert(1 / (tot_incl_all_scans_on_tgt * sqrt(2 * ((obj.db2ratio(obj.rx_single_pulse_pwr_db_mid) * u.W) * tau) / n_0)), u.Hz);

                obj.model_cache('doppler_precision_mid') = vpa(simplify(func_result));
                val = obj.model_cache('doppler_precision_mid');
            end
        end

        function val = get.doppler_precision_far(obj)
            if isKey(obj.model_cache, 'doppler_precision_far')
                val = obj.model_cache('doppler_precision_far');
            else
                u = symunit;

                tau = unitConvert(obj.tx_pulse_width, u.sec);
                n_0 = unitConvert(unitConvert(u.k_B, u.J / u.K) * obj.t_sys, (u.W / u.K));
                tot_incl_all_scans_on_tgt = (obj.scan_qty_on_tgt_intent * (obj.pulses_on_target - 1)) / obj.tx_prf;

                func_result = unitConvert(1 / (tot_incl_all_scans_on_tgt * sqrt(2 * ((obj.db2ratio(obj.rx_single_pulse_pwr_db_far) * u.W) * tau) / n_0)), u.Hz);

                obj.model_cache('doppler_precision_far') = vpa(simplify(func_result));
                val = obj.model_cache('doppler_precision_far');
            end
        end

        function val = get.worst_case_doppler_precision(obj)
            u = symunit;

            function_result = max([separateUnits(unitConvert(obj.doppler_precision_near, u.Hz)), ...
                                       separateUnits(unitConvert(obj.doppler_precision_mid, u.Hz)), ...
                                       separateUnits(unitConvert(obj.doppler_precision_far, u.Hz))]) * u.Hz;

            val = function_result;
        end

        function val = get.max_expected_doppler_freq_near(obj)
            if isKey(obj.model_cache, 'max_expected_doppler_freq_near')
                val = obj.model_cache('max_expected_doppler_freq_near');
            else
                u = symunit;

                tot_rel_speed = obj.const_tgt_speed_max + obj.const_ac_gnd_speed;
                v_radial_speed = tot_rel_speed * sin(unitConvert(90 * u.deg, u.rad) - unitConvert(obj.ant_bs_grazing_ang_near, u.rad));

                func_result = unitConvert((2 * unitConvert(v_radial_speed, (u.m / u.sec))) / obj.freq2wavelen(obj.tx_freq), u.Hz);

                obj.model_cache('max_expected_doppler_freq_near') = vpa(simplify(func_result));
                val = obj.model_cache('max_expected_doppler_freq_near');
            end
        end

        function val = get.max_expected_doppler_freq_mid(obj)
            if isKey(obj.model_cache, 'max_expected_doppler_freq_mid')
                val = obj.model_cache('max_expected_doppler_freq_mid');
            else
                u = symunit;

                tot_rel_speed = obj.const_tgt_speed_max + obj.const_ac_gnd_speed;
                v_radial_speed = tot_rel_speed * sin(unitConvert(90 * u.deg, u.rad) - unitConvert(obj.ant_bs_grazing_ang_mid, u.rad));

                func_result = unitConvert((2 * unitConvert(v_radial_speed, (u.m / u.sec))) / obj.freq2wavelen(obj.tx_freq), u.Hz);

                obj.model_cache('max_expected_doppler_freq_mid') = vpa(simplify(func_result));
                val = obj.model_cache('max_expected_doppler_freq_mid');
            end
        end

        function val = get.max_expected_doppler_freq_far(obj)
            if isKey(obj.model_cache, 'max_expected_doppler_freq_far')
                val = obj.model_cache('max_expected_doppler_freq_far');
            else
                u = symunit;

                tot_rel_speed = obj.const_tgt_speed_max + obj.const_ac_gnd_speed;
                v_radial_speed = tot_rel_speed * sin(unitConvert(90 * u.deg, u.rad) - unitConvert(obj.ant_bs_grazing_ang_far, u.rad));

                func_result = unitConvert((2 * unitConvert(v_radial_speed, (u.m / u.sec))) / obj.freq2wavelen(obj.tx_freq), u.Hz);

                obj.model_cache('max_expected_doppler_freq_far') = vpa(simplify(func_result));
                val = obj.model_cache('max_expected_doppler_freq_far');
            end
        end

        function val = get.worst_case_max_expected_doppler_freq(obj)
            u = symunit;

            function_result = max([separateUnits(unitConvert(obj.max_expected_doppler_freq_near, u.Hz)), ...
                                       separateUnits(unitConvert(obj.max_expected_doppler_freq_mid, u.Hz)), ...
                                       separateUnits(unitConvert(obj.max_expected_doppler_freq_far, u.Hz))]) * u.Hz;

            val = function_result;
        end

        function val = get.nyquist_reqd_for_max_doppler_near(obj)
            if isKey(obj.model_cache, 'nyquist_reqd_for_max_doppler_near')
                val = obj.model_cache('nyquist_reqd_for_max_doppler_near');
            else
                func_result = 2 * obj.max_expected_doppler_freq_near;

                obj.model_cache('nyquist_reqd_for_max_doppler_near') = vpa(simplify(func_result));
                val = obj.model_cache('nyquist_reqd_for_max_doppler_near');
            end
        end

        function val = get.nyquist_reqd_for_max_doppler_mid(obj)
            if isKey(obj.model_cache, 'nyquist_reqd_for_max_doppler_mid')
                val = obj.model_cache('nyquist_reqd_for_max_doppler_mid');
            else
                func_result = 2 * obj.max_expected_doppler_freq_mid;

                obj.model_cache('nyquist_reqd_for_max_doppler_mid') = vpa(simplify(func_result));
                val = obj.model_cache('nyquist_reqd_for_max_doppler_mid');
            end
        end

        function val = get.nyquist_reqd_for_max_doppler_far(obj)
            if isKey(obj.model_cache, 'nyquist_reqd_for_max_doppler_far')
                val = obj.model_cache('nyquist_reqd_for_max_doppler_far');
            else
                func_result = 2 * obj.max_expected_doppler_freq_far;

                obj.model_cache('nyquist_reqd_for_max_doppler_far') = vpa(simplify(func_result));
                val = obj.model_cache('nyquist_reqd_for_max_doppler_far');
            end
        end

        function val = get.worst_case_nyquist_reqd_for_max_doppler(obj)
            u = symunit;

            function_result = max([separateUnits(unitConvert(obj.nyquist_reqd_for_max_doppler_near, u.Hz)), ...
                                       separateUnits(unitConvert(obj.nyquist_reqd_for_max_doppler_mid, u.Hz)), ...
                                       separateUnits(unitConvert(obj.nyquist_reqd_for_max_doppler_far, u.Hz))]) * u.Hz;

            val = function_result;
        end

        function val = get.ant_bs_grazing_ang_far(obj)
            if isKey(obj.model_cache, 'ant_bs_grazing_ang_far')
                val = obj.model_cache('ant_bs_grazing_ang_far');
            else
                u = symunit;
                inclination_ang_mid = 90 * u.deg - unitConvert(obj.ant_bs_grazing_ang_mid, u.deg);
                inclination_ang_far = inclination_ang_mid + (unitConvert(obj.ant_hpbw_elevation, u.deg) / 2);
                func_result = 90 * u.deg - inclination_ang_far;

                obj.model_cache('ant_bs_grazing_ang_far') = vpa(simplify(func_result));
                val = obj.model_cache('ant_bs_grazing_ang_far');
            end
        end

        function val = get.ant_bs_grazing_ang_near(obj)
            if isKey(obj.model_cache, 'ant_bs_grazing_ang_near')
                val = obj.model_cache('ant_bs_grazing_ang_near');
            else
                u = symunit;
                inclination_ang_mid = 90 * u.deg - unitConvert(obj.ant_bs_grazing_ang_mid, u.deg);
                inclination_ang_near = inclination_ang_mid - (unitConvert(obj.ant_hpbw_elevation, u.deg) / 2);
                func_result = 90 * u.deg - inclination_ang_near;

                obj.model_cache('ant_bs_grazing_ang_near') = vpa(simplify(func_result));
                val = obj.model_cache('ant_bs_grazing_ang_near');
            end
        end

        function val = get.avg_tgt_xs_area_near(obj)
            if isKey(obj.model_cache, 'avg_tgt_xs_area_near')
                val = obj.model_cache('avg_tgt_xs_area_near');
            else
                u = symunit;
                grz_ang_deg = double(separateUnits(unitConvert(obj.ant_bs_grazing_ang_near, u.deg)));

                func_result = ((obj.const_rcs_p1 * grz_ang_deg ^ 4) + (obj.const_rcs_p2 * grz_ang_deg ^ 3) + ...
                    (obj.const_rcs_p3 * grz_ang_deg ^ 2) + (obj.const_rcs_p4 * grz_ang_deg) + obj.const_rcs_p5) * ...
                    (u.m ^ 2);

                obj.model_cache('avg_tgt_xs_area_near') = vpa(simplify(func_result));
                val = obj.model_cache('avg_tgt_xs_area_near');
            end
        end

        function val = get.avg_tgt_xs_area_mid(obj)
            if isKey(obj.model_cache, 'avg_tgt_xs_area_mid')
                val = obj.model_cache('avg_tgt_xs_area_mid');
            else
                u = symunit;
                grz_ang_deg = double(separateUnits(unitConvert(obj.ant_bs_grazing_ang_mid, u.deg)));

                func_result = ((obj.const_rcs_p1 * grz_ang_deg ^ 4) + (obj.const_rcs_p2 * grz_ang_deg ^ 3) + ...
                    (obj.const_rcs_p3 * grz_ang_deg ^ 2) + (obj.const_rcs_p4 * grz_ang_deg) + obj.const_rcs_p5) * ...
                    (u.m ^ 2);

                obj.model_cache('avg_tgt_xs_area_mid') = vpa(simplify(func_result));
                val = obj.model_cache('avg_tgt_xs_area_mid');
            end
        end

        function val = get.avg_tgt_xs_area_far(obj)
            if isKey(obj.model_cache, 'avg_tgt_xs_area_far')
                val = obj.model_cache('avg_tgt_xs_area_far');
            else
                u = symunit;
                grz_ang_deg = double(separateUnits(unitConvert(obj.ant_bs_grazing_ang_far, u.deg)));

                func_result = ((obj.const_rcs_p1 * grz_ang_deg ^ 4) + (obj.const_rcs_p2 * grz_ang_deg ^ 3) + ...
                    (obj.const_rcs_p3 * grz_ang_deg ^ 2) + (obj.const_rcs_p4 * grz_ang_deg) + obj.const_rcs_p5) * ...
                    (u.m ^ 2);

                obj.model_cache('avg_tgt_xs_area_far') = vpa(simplify(func_result));
                val = obj.model_cache('avg_tgt_xs_area_far');
            end
        end

        function val = get.t_sys(obj)
            u = symunit;
            freq_ghz = separateUnits(unitConvert(obj.tx_freq, u.GHz));
            if freq_ghz == 37
                val = obj.const_tsys_37g_degk * u.K;
            elseif freq_ghz == 90
                val = obj.const_tsys_90g_degk * u.K;
            elseif freq_ghz == 150
                val = obj.const_tsys_150g_degk * u.K;
            else
                error('Function input "obj.tx_freq" must be one of "37GHz", "90GHz", or "150GHz".')
            end
        end

        function val = get.l_atm_oneway_db_near(obj)
            if isKey(obj.model_cache, 'l_atm_oneway_db_near')
                val = obj.model_cache('l_atm_oneway_db_near');
            else
                u = symunit;

                freq_ghz = separateUnits(unitConvert(obj.tx_freq, u.GHz));

                if freq_ghz == 37
                    db_loss_factor = obj.const_latm_37g_1way_dbkm;
                elseif freq_ghz == 90
                    db_loss_factor = obj.const_latm_90g_1way_dbkm;
                elseif freq_ghz == 150
                    db_loss_factor = obj.const_latm_150g_1way_dbkm;
                else
                    error('Function input "obj.tx_freq" must be one of "37GHz", "90GHz", or "150GHz".')
                end

                % Get bs dist affected by latm
                bs_rng_affected_by_latm = obj.const_latm_eff_max_altitude / sin(unitConvert(obj.ant_bs_grazing_ang_near, u.rad));

                % NB: The following shouldn't ever happen due to aircraft alt minimums, but check for this situation anyway
                if double(separateUnits(unitConvert(obj.bs_rng_near, u.km))) < double(separateUnits(unitConvert(bs_rng_affected_by_latm, u.km)))
                    bs_rng_affected_by_latm = obj.bs_rng_near;
                end

                % Calc loss over the affected bs rng
                func_result = db_loss_factor * double(separateUnits(unitConvert(bs_rng_affected_by_latm, u.km)));

                obj.model_cache('l_atm_oneway_db_near') = func_result;
                val = obj.model_cache('l_atm_oneway_db_near');
            end
        end

        function val = get.l_atm_oneway_db_mid(obj)
            if isKey(obj.model_cache, 'l_atm_oneway_db_mid')
                val = obj.model_cache('l_atm_oneway_db_mid');
            else
                u = symunit;

                freq_ghz = separateUnits(unitConvert(obj.tx_freq, u.GHz));

                if freq_ghz == 37
                    db_loss_factor = obj.const_latm_37g_1way_dbkm;
                elseif freq_ghz == 90
                    db_loss_factor = obj.const_latm_90g_1way_dbkm;
                elseif freq_ghz == 150
                    db_loss_factor = obj.const_latm_150g_1way_dbkm;
                else
                    error('Function input "obj.tx_freq" must be one of "37GHz", "90GHz", or "150GHz".')
                end

                % Get bs dist affected by latm
                bs_rng_affected_by_latm = obj.const_latm_eff_max_altitude / sin(unitConvert(obj.ant_bs_grazing_ang_mid, u.rad));

                % NB: The following shouldn't ever happen due to aircraft alt minimums, but check for this situation anyway
                if double(separateUnits(unitConvert(obj.bs_rng_mid, u.km))) < double(separateUnits(unitConvert(bs_rng_affected_by_latm, u.km)))
                    bs_rng_affected_by_latm = obj.bs_rng_mid;
                end

                % Calc loss over the affected bs rng
                func_result = db_loss_factor * double(separateUnits(unitConvert(bs_rng_affected_by_latm, u.km)));

                obj.model_cache('l_atm_oneway_db_mid') = func_result;
                val = obj.model_cache('l_atm_oneway_db_mid');
            end
        end

        function val = get.l_atm_oneway_db_far(obj)
            if isKey(obj.model_cache, 'l_atm_oneway_db_far')
                val = obj.model_cache('l_atm_oneway_db_far');
            else
                u = symunit;

                freq_ghz = separateUnits(unitConvert(obj.tx_freq, u.GHz));

                if freq_ghz == 37
                    db_loss_factor = obj.const_latm_37g_1way_dbkm;
                elseif freq_ghz == 90
                    db_loss_factor = obj.const_latm_90g_1way_dbkm;
                elseif freq_ghz == 150
                    db_loss_factor = obj.const_latm_150g_1way_dbkm;
                else
                    error('Function input "obj.tx_freq" must be one of "37GHz", "90GHz", or "150GHz".')
                end

                % Get bs dist affected by latm
                bs_rng_affected_by_latm = obj.const_latm_eff_max_altitude / sin(unitConvert(obj.ant_bs_grazing_ang_far, u.rad));

                % NB: The following shouldn't ever happen due to aircraft alt minimums, but check for this situation anyway
                if double(separateUnits(unitConvert(obj.bs_rng_far, u.km))) < double(separateUnits(unitConvert(bs_rng_affected_by_latm, u.km)))
                    bs_rng_affected_by_latm = obj.bs_rng_far;
                end

                % Calc loss over the affected bs rng
                func_result = db_loss_factor * double(separateUnits(unitConvert(bs_rng_affected_by_latm, u.km)));

                obj.model_cache('l_atm_oneway_db_far') = func_result;
                val = obj.model_cache('l_atm_oneway_db_far');
            end
        end

        function val = get.l_atm_roundtrip_db_near(obj)
            val = obj.l_atm_oneway_db_near * 2;
        end

        function val = get.l_atm_roundtrip_db_mid(obj)
            val = obj.l_atm_oneway_db_mid * 2;
        end

        function val = get.l_atm_roundtrip_db_far(obj)
            val = obj.l_atm_oneway_db_far * 2;
        end

        function val = get.rx_minus3dB_bw_predet(obj)
            if isKey(obj.model_cache, 'rx_minus3dB_bw_predet')
                val = obj.model_cache('rx_minus3dB_bw_predet');
            else
                u = symunit;
                tau = double(separateUnits(unitConvert(obj.tx_pulse_width, u.sec)));
                func_result = (1 / tau) * u.Hz;

                obj.model_cache('rx_minus3dB_bw_predet') = vpa(simplify(func_result));
                val = obj.model_cache('rx_minus3dB_bw_predet');
            end
        end

        function val = get.ant_hpbw_elevation(obj)
            if isKey(obj.model_cache, 'ant_hpbw_elevation')
                val = obj.model_cache('ant_hpbw_elevation');
            else
                u = symunit;
                % NB: Force appending radians because all units in the calc cancel out
                func_result = (1.2 * obj.freq2wavelen(obj.tx_freq) / obj.ant_dim_elev) * u.rad;

                obj.model_cache('ant_hpbw_elevation') = vpa(simplify(func_result));
                val = obj.model_cache('ant_hpbw_elevation');
            end
        end

        function val = get.ant_hpbw_azimuth(obj)
            if isKey(obj.model_cache, 'ant_hpbw_azimuth')
                val = obj.model_cache('ant_hpbw_azimuth');
            else
                u = symunit;
                % NB: Force appending radians because all units in the calc cancel out
                func_result = (1.2 * obj.freq2wavelen(obj.tx_freq) / obj.ant_dim_azim) * u.rad;

                obj.model_cache('ant_hpbw_azimuth') = vpa(simplify(func_result));
                val = obj.model_cache('ant_hpbw_azimuth');
            end
        end

        function val = get.tx_ant_gain(obj)
            if isKey(obj.model_cache, 'tx_ant_gain')
                val = obj.model_cache('tx_ant_gain');
            else
                u = symunit;
                func_result = (0.6 * 4 * pi) / ...
                    (separateUnits(unitConvert(obj.ant_hpbw_elevation, u.rad)) * separateUnits(unitConvert(obj.ant_hpbw_azimuth, u.rad)));

                obj.model_cache('tx_ant_gain') = vpa(simplify(func_result));
                val = obj.model_cache('tx_ant_gain');
            end
        end

        function val = get.tx_ant_gain_db(obj)
            val = obj.ratio2db(obj.tx_ant_gain);
        end

        function val = get.pulse_rng_res_near(obj)
            if isKey(obj.model_cache, 'pulse_rng_res_near')
                val = obj.model_cache('pulse_rng_res_near');
            else
                u = symunit;
                func_result = (unitConvert(u.c_0, u.m / u.s) * obj.tx_pulse_width) / (2 * cos(unitConvert(obj.ant_bs_grazing_ang_near, u.rad)));

                obj.model_cache('pulse_rng_res_near') = vpa(simplify(func_result));
                val = obj.model_cache('pulse_rng_res_near');
            end
        end

        function val = get.pulse_rng_res_mid(obj)
            if isKey(obj.model_cache, 'pulse_rng_res_mid')
                val = obj.model_cache('pulse_rng_res_mid');
            else
                u = symunit;
                func_result = (unitConvert(u.c_0, u.m / u.s) * obj.tx_pulse_width) / (2 * cos(unitConvert(obj.ant_bs_grazing_ang_mid, u.rad)));

                obj.model_cache('pulse_rng_res_mid') = vpa(simplify(func_result));
                val = obj.model_cache('pulse_rng_res_mid');
            end
        end

        function val = get.pulse_rng_res_far(obj)
            if isKey(obj.model_cache, 'pulse_rng_res_far')
                val = obj.model_cache('pulse_rng_res_far');
            else
                u = symunit;
                func_result = (unitConvert(u.c_0, u.m / u.s) * obj.tx_pulse_width) / (2 * cos(unitConvert(obj.ant_bs_grazing_ang_far, u.rad)));

                obj.model_cache('pulse_rng_res_far') = vpa(simplify(func_result));
                val = obj.model_cache('pulse_rng_res_far');
            end
        end

        function val = get.worst_case_pulse_rng_res(obj)
            val = min([obj.pulse_rng_res_near, ...
                           obj.pulse_rng_res_mid, ...
                           obj.pulse_rng_res_far]);
        end

        function val = get.pulse_azim_res_near(obj)
            if isKey(obj.model_cache, 'pulse_azim_res_near')
                val = obj.model_cache('pulse_azim_res_near');
            else
                u = symunit;
                func_result = unitConvert(obj.bs_rng_near, u.m) * separateUnits(unitConvert(obj.ant_hpbw_azimuth, u.rad));

                obj.model_cache('pulse_azim_res_near') = vpa(simplify(func_result));
                val = obj.model_cache('pulse_azim_res_near');
            end
        end

        function val = get.pulse_azim_res_mid(obj)
            if isKey(obj.model_cache, 'pulse_azim_res_mid')
                val = obj.model_cache('pulse_azim_res_mid');
            else
                u = symunit;
                func_result = unitConvert(obj.bs_rng_mid, u.m) * separateUnits(unitConvert(obj.ant_hpbw_azimuth, u.rad));

                obj.model_cache('pulse_azim_res_mid') = vpa(simplify(func_result));
                val = obj.model_cache('pulse_azim_res_mid');
            end
        end

        function val = get.pulse_azim_res_far(obj)
            if isKey(obj.model_cache, 'pulse_azim_res_far')
                val = obj.model_cache('pulse_azim_res_far');
            else
                u = symunit;
                func_result = unitConvert(obj.bs_rng_far, u.m) * separateUnits(unitConvert(obj.ant_hpbw_azimuth, u.rad));

                obj.model_cache('pulse_azim_res_far') = vpa(simplify(func_result));
                val = obj.model_cache('pulse_azim_res_far');
            end
        end

        function val = get.worst_case_pulse_azim_res(obj)
            val = min([obj.pulse_azim_res_near, ...
                           obj.pulse_azim_res_mid, ...
                           obj.pulse_azim_res_far]);
        end

        function val = get.ifov_near(obj)
            if isKey(obj.model_cache, 'ifov_near')
                val = obj.model_cache('ifov_near');
            else
                func_result = obj.pulse_rng_res_near * obj.pulse_azim_res_near;

                obj.model_cache('ifov_near') = vpa(simplify(func_result));
                val = obj.model_cache('ifov_near');
            end
        end

        function val = get.ifov_mid(obj)
            if isKey(obj.model_cache, 'ifov_mid')
                val = obj.model_cache('ifov_mid');
            else
                func_result = obj.pulse_rng_res_mid * obj.pulse_azim_res_mid;

                obj.model_cache('ifov_mid') = vpa(simplify(func_result));
                val = obj.model_cache('ifov_mid');
            end
        end

        function val = get.ifov_far(obj)
            if isKey(obj.model_cache, 'ifov_far')
                val = obj.model_cache('ifov_far');
            else
                func_result = obj.pulse_rng_res_far * obj.pulse_azim_res_far;

                obj.model_cache('ifov_far') = vpa(simplify(func_result));
                val = obj.model_cache('ifov_far');
            end
        end

        function val = get.time_on_target(obj)
            if isKey(obj.model_cache, 'time_on_target')
                val = obj.model_cache('time_on_target');
            else
                u = symunit;
                func_result = (1 / separateUnits(unitConvert(obj.ant_spin_rate, u.rps))) * ...
                    (unitConvert(obj.ant_hpbw_azimuth, u.deg) / (360 * u.deg)) * ...
                    u.s;

                obj.model_cache('time_on_target') = vpa(simplify(func_result));
                val = obj.model_cache('time_on_target');
            end
        end

        function val = get.doppler_time_on_target(obj)
            if isKey(obj.model_cache, 'doppler_time_on_target')
                val = obj.model_cache('doppler_time_on_target');
            else
                func_result = obj.time_on_target * obj.scan_qty_on_tgt_intent;
                obj.model_cache('doppler_time_on_target') = vpa(simplify(func_result));
                val = obj.model_cache('doppler_time_on_target');
            end
        end

        function val = get.pulses_on_target(obj)
            if isKey(obj.model_cache, 'pulses_on_target')
                val = obj.model_cache('pulses_on_target');
            else
                % NB: Don't round the POT value down yet (partial pulses normally don't count)
                %     because of a special case in HW04-P1.
                [pot_val, pot_unit] = separateUnits(simplify(obj.tx_prf * obj.time_on_target));

                % Perform tiebreaker which guarantees a "correct" result that matches
                % the value given in the answer sheet for HW01-P1.
                %
                % NB: Using vpa() here b/c Matlab complains that mod(pot_val, 1) is still
                %     a symbolic unit (apparently exact fracs == symunits)
                if vpa(mod(pot_val, 1)) >= 0.99
                    func_result = ceil(pot_val) * pot_unit;
                else
                    func_result = floor(pot_val) * pot_unit;
                end

                obj.model_cache('pulses_on_target') = vpa(simplify(func_result));
                val = obj.model_cache('pulses_on_target');
            end
        end

        function val = get.rtt_near(obj)
            if isKey(obj.model_cache, 'rtt_near')
                val = obj.model_cache('rtt_near');
            else
                u = symunit;

                func_result = simplify((obj.bs_rng_near * 2) / u.c_0);

                obj.model_cache('rtt_near') = vpa(simplify(func_result));
                val = obj.model_cache('rtt_near');
            end
        end

        function val = get.rtt_mid(obj)
            if isKey(obj.model_cache, 'rtt_mid')
                val = obj.model_cache('rtt_mid');
            else
                u = symunit;

                func_result = simplify((obj.bs_rng_mid * 2) / u.c_0);

                obj.model_cache('rtt_mid') = vpa(simplify(func_result));
                val = obj.model_cache('rtt_mid');
            end
        end

        function val = get.rtt_far(obj)
            if isKey(obj.model_cache, 'rtt_far')
                val = obj.model_cache('rtt_far');
            else
                u = symunit;

                func_result = simplify((obj.bs_rng_far * 2) / u.c_0);

                obj.model_cache('rtt_far') = vpa(simplify(func_result));
                val = obj.model_cache('rtt_far');
            end
        end

        function val = get.scan_fov_overlap_pct(obj)
            if isKey(obj.model_cache, 'scan_fov_overlap_pct')
                val = obj.model_cache('scan_fov_overlap_pct');
            else
                u = symunit;

                dist_gndtrk_far = obj.bs_rng_far * cos(unitConvert(obj.ant_bs_grazing_ang_far, u.rad));
                dist_gndtrk_near = obj.bs_rng_near * cos(unitConvert(obj.ant_bs_grazing_ang_near, u.rad));
                dist_scan_overlap = dist_gndtrk_far - (dist_gndtrk_near + obj.const_ac_gnd_speed * obj.t_spin);

                func_result = double(simplify(dist_scan_overlap / (obj.fov_range)));

                obj.model_cache('scan_fov_overlap_pct') = func_result;
                val = obj.model_cache('scan_fov_overlap_pct');
            end
        end

        function val = get.max_prf_supported(obj)
            if isKey(obj.model_cache, 'max_prf_supported')
                val = obj.model_cache('max_prf_supported');
            else
                u = symunit;
                func_result = unitConvert(simplify(1 / (obj.rtt_far - obj.rtt_near)), u.Hz);

                obj.model_cache('max_prf_supported') = vpa(simplify(func_result));
                val = obj.model_cache('max_prf_supported');
            end
        end

        function val = get.min_spin_rate_supported(obj)
            warning('Min Reqd. Spin Rate is +0.487 dB from DrJ value. This calculation and dependent functions may yield inaccurate results!')
            if isKey(obj.model_cache, 'min_spin_rate_supported')
                val = obj.model_cache('min_spin_rate_supported');
            else
                u = symunit;

                overlap_dist = obj.scan_fov_overlap_pct * obj.fov_range;
                tot_rel_speed = obj.const_tgt_speed_max + obj.const_ac_gnd_speed;

                tgt_time_in_overlap_box = overlap_dist / tot_rel_speed;

                time_per_spin = vpa(simplify(tgt_time_in_overlap_box / obj.scan_qty_on_tgt_intent));

                func_result = (60 / separateUnits(unitConvert(time_per_spin, u.sec))) * u.rpm;

                obj.model_cache('min_spin_rate_supported') = vpa(simplify(func_result));
                val = obj.model_cache('min_spin_rate_supported');
            end
        end

        function val = get.requirements_check(obj)
            u = symunit;
            specs = readstruct(obj.const_requirements_json_file);
            results = configureDictionary('string', 'uint8');

            %% Swath Width
            if separateUnits(unitConvert(obj.swath_width, u.km)) >= getfield(specs, 'swath_width', 'required', 'value')
                results('swath_width') = 1;
            else
                results('swath_width') = 0;
            end

            %% Tx Pulse Width
            warning('Couldn''t find a spec to eval pulse width against!')

            %% Ant Dimension Azimuth
            if separateUnits(unitConvert(obj.ant_dim_azim, u.m)) <= getfield(specs, 'ant_dim_azim', 'required', 'value')
                results('ant_dim_azim') = 1;
            else
                results('ant_dim_azim') = 0;
            end

            %% Ant Dimension Elevation
            if separateUnits(unitConvert(obj.ant_dim_elev, u.m)) <= getfield(specs, 'ant_dim_elev', 'required', 'value')
                results('ant_dim_elev') = 1;
            else
                results('ant_dim_elev') = 0;
            end

            %% Ant Grazing Ang Far
            if separateUnits(unitConvert(obj.ant_bs_grazing_ang_far, u.deg)) >= specs.ant_bs_grazing_ang_far.required.value
                results('ant_bs_grazing_ang_far') = 1;
            else
                results('ant_bs_grazing_ang_far') = 0;
            end

            %% PRF Acceptable for Delta Range
            if separateUnits(unitConvert(obj.tx_prf, u.Hz)) <= separateUnits(unitConvert(obj.max_prf_supported, u.Hz))
                results('prf_compat_with_delta_range') = 1;
            else
                results('prf_compat_with_delta_range') = 0;
            end

            %% T_fa Spin Ratio
            if obj.tfa_tspin_ratio >= getfield(specs, 'tfa_tspin_ratio', 'required', 'value')
                results('tfa_tspin_ratio') = 1;
            else
                results('tfa_tspin_ratio') = 0;
            end

            %% Ant Spin Rate
            if separateUnits(unitConvert(obj.ant_spin_rate, u.rpm)) <= getfield(specs, 'ant_spin_rate', 'required', 'value')
                results('ant_spin_rate') = 1;
            else
                results('ant_spin_rate') = 0;
            end

            %% Scans on Target Quantity
            if obj.scan_qty_on_tgt_intent >= getfield(specs, 'scan_qty_on_tgt_intent', 'required', 'value')
                results('scan_qty_on_tgt_intent') = 1;
            else
                results('scan_qty_on_tgt_intent') = 0;
            end

            %% Spin Rate Satisfies "No Missed Scan" Qty Intent
            if separateUnits(unitConvert(obj.ant_spin_rate, u.rpm)) >= separateUnits(unitConvert(obj.min_spin_rate_supported, u.rpm))
                results('ant_spin_rate_ensures_nomissedtgt') = 1;
            else
                results('ant_spin_rate_ensures_nomissedtgt') = 0;
            end

            %% T_warn
            if separateUnits(unitConvert(obj.t_warn, u.sec)) >= getfield(specs, 't_warn', {1}, 'required', 'value')
                results('t_warn') = 1;
            else
                results('t_warn') = 0;
            end

            %% Tx Duty Cycle for Search & Doppler Modes
            if separateUnits(unitConvert(obj.tx_duty_cycle, u.Hz)) <= getfield(specs, 'tx_duty_cycle', {1}, 'required', 'value')
                results('tx_duty_cycle_search') = 1;
            else
                results('tx_duty_cycle_search') = 0;
            end

            if separateUnits(unitConvert(obj.tx_duty_cycle, u.Hz)) <= getfield(specs, 'tx_duty_cycle', {2}, 'required', 'value')
                results('tx_duty_cycle_doppler') = 1;
            else
                results('tx_duty_cycle_doppler') = 0;
            end

            %% Range Gate Resolution on Surface
            u = symunit;

            wc_range_gate_m = min([separateUnits(unitConvert(obj.pulse_rng_res_near, u.m)), ...
                                       separateUnits(unitConvert(obj.pulse_rng_res_mid, u.m)), ...
                                       separateUnits(unitConvert(obj.pulse_rng_res_far, u.m))]);

            if wc_range_gate_m >= getfield(specs, 'fov_range', 'required', 'value')
                results('fov_range_gate') = 1;
            else
                results('fov_range_gate') = 0;
            end

            %% Azimuth Resolution on Surface (Delta Az)
            if separateUnits(unitConvert(obj.fov_azimuth, u.m)) >= getfield(specs, 'fov_azimuth', 'required', 'value')
                results('fov_azimuth') = 1;
            else
                results('fov_azimuth') = 0;
            end

            %% Probability of Detection Near/Mid/Far
            if obj.p_det_multi_pulse_near >= getfield(specs, 'tgt_det', {1}, 'required', 'value')
                results('p_det_for_tot_near') = 1;
            else
                results('p_det_for_tot_near') = 0;
            end

            if obj.p_det_multi_pulse_mid >= getfield(specs, 'tgt_det', {1}, 'required', 'value')
                results('p_det_for_tot_mid') = 1;
            else
                results('p_det_for_tot_mid') = 0;
            end

            if obj.p_det_multi_pulse_far >= getfield(specs, 'tgt_det', {1}, 'required', 'value')
                results('p_det_for_tot_far') = 1;
            else
                results('p_det_for_tot_far') = 0;
            end

            %% PRF
            if separateUnits(unitConvert(obj.tx_prf, u.Hz)) <= getfield(specs, 'tx_prf', 'required', 'value')
                results('tx_prf') = 1;
            else
                results('tx_prf') = 0;
            end

            %% PRF Satisfies Nyquist Minimums
            if separateUnits(unitConvert(obj.tx_prf, u.kHz)) >= separateUnits(unitConvert(obj.worst_case_nyquist_reqd_for_max_doppler, u.kHz))
                results('prf_meets_nyquist_wc') = 1;
            else
                results('prf_meets_nyquist_wc') = 0;
            end

            %% Doppler Precision Worst Case
            if separateUnits(unitConvert(obj.worst_case_doppler_precision, u.Hz)) <= getfield(specs, 'doppler_precision', {1}, 'required', 'value')
                results('doppler_precision') = 1;
            else
                results('doppler_precision') = 0;
            end

            % NB: The following requirement checks DON'T appear on DrJ check sheets but are still needed

            %% Tx Power
            if separateUnits(unitConvert(obj.tx_power, u.W)) <= specs.tx_power.required.value
                results('tx_power') = 1;
            else
                results('tx_power') = 0;
            end

            val = results;
        end

        function val = get.goals_check(obj)
            u = symunit;
            specs = readstruct(obj.const_requirements_json_file);
            results = configureDictionary('string', 'single');

            %% Ant Dimension Azimuth
            ant_dim_azim_m = double(separateUnits(unitConvert(obj.ant_dim_azim, u.m)));
            if ant_dim_azim_m <= specs.ant_dim_azim.goal.value
                results('ant_dim_azim') = 1;
            elseif ant_dim_azim_m <= specs.ant_dim_azim.required.value
                tmp_azim_linspace = linspace(double(specs.ant_dim_azim.required.value), double(specs.ant_dim_azim.goal.value));
                results('ant_dim_azim') = single(knnsearch(tmp_azim_linspace', ant_dim_azim_m)) / 100;
            else
                results('ant_dim_azim') = 0;
            end

            %% Ant Dimension Elevation
            ant_dim_elev_m = double(separateUnits(unitConvert(obj.ant_dim_elev, u.m)));
            if ant_dim_elev_m <= specs.ant_dim_elev.goal.value
                results('ant_dim_elev') = 1;
            elseif ant_dim_elev_m <= specs.ant_dim_elev.required.value
                tmp_elev_linspace = linspace(double(specs.ant_dim_elev.required.value), double(specs.ant_dim_elev.goal.value));
                results('ant_dim_elev') = single(knnsearch(tmp_elev_linspace', ant_dim_elev_m)) / 100;
            else
                results('ant_dim_elev') = 0;
            end

            %% Scans on Target Quantity
            if obj.scan_qty_on_tgt_intent >= specs.scan_qty_on_tgt_intent.goal.value
                results('scan_qty_on_tgt_intent') = 1;
            elseif obj.scan_qty_on_tgt_intent >= specs.scan_qty_on_tgt_intent.required.value
                tmp_scanontgt_linspace = linspace(double(specs.scan_qty_on_tgt_intent.required.value), double(specs.scan_qty_on_tgt_intent.goal.value));
                results('scan_qty_on_tgt_intent') = single(knnsearch(tmp_scanontgt_linspace', double(obj.scan_qty_on_tgt_intent))) / 100;
            else
                results('scan_qty_on_tgt_intent') = 0;
            end

            %% Ant Spin Rate
            ant_spin_rate_rpm = double(separateUnits(unitConvert(obj.ant_spin_rate, u.rpm)));
            if ant_spin_rate_rpm <= specs.ant_spin_rate.goal.value
                results('ant_spin_rate') = 1;
            elseif ant_spin_rate_rpm <= specs.ant_spin_rate.required.value
                mp_spinrt_linspace = linspace(double(specs.ant_spin_rate.required.value), double(specs.ant_spin_rate.goal.value));
                results('ant_spin_rate') = single(knnsearch(mp_spinrt_linspace', ant_spin_rate_rpm)) / 100;
            else
                results('ant_spin_rate') = 0;
            end

            %% T_warn
            t_warn_sec = double(separateUnits(unitConvert(obj.t_warn, u.sec)));
            if t_warn_sec >= specs.t_warn.goal.value
                results('t_warn') = 1;
            elseif t_warn_sec >= specs.t_warn.required.value
                tmp_twarn_linspace = linspace(double(specs.t_warn.required.value), double(specs.t_warn.goal.value));
                results('t_warn') = single(knnsearch(tmp_twarn_linspace', t_warn_sec)) / 100;
            else
                results('t_warn') = 0;
            end

            %% N out of M Probability of Detection
            wc_p_det_nofm = min([obj.p_det_n_of_m_near, obj.p_det_n_of_m_mid, obj.p_det_n_of_m_far]);
            if wc_p_det_nofm >= getfield(specs, 'tgt_det', {2}, 'goal', 'value')
                results('p_det_nofm_wc') = 1;
                % NB: This compare against the single-pulse required probability isn't in the spec, but should still be valid here
            elseif wc_p_det_nofm >= getfield(specs, 'tgt_det', {1}, 'required', 'value')
                tmp_nofm_linspace = linspace(double(getfield(specs, 'tgt_det', {2}, 'goal', 'value')), ...
                    double(getfield(specs, 'tgt_det', {1}, 'required', 'value')));
                results('p_det_nofm_wc') = single(knnsearch(tmp_nofm_linspace', wc_p_det_nofm)) / 100;
            else
                results('p_det_nofm_wc') = 0;
            end

            %% Doppler Precision
            worst_case_doppler_precision_hz = double(separateUnits(unitConvert(obj.worst_case_doppler_precision, u.Hz)));
            if worst_case_doppler_precision_hz <= specs.doppler_precision.goal.value
                results('doppler_precision') = 1;
            elseif worst_case_doppler_precision_hz <= specs.doppler_precision.required.value
                tmp_dopprec_linspace = linspace(double(specs.doppler_precision.required.value), double(specs.doppler_precision.goal.value));
                results('doppler_precision') = single(knnsearch(tmp_dopprec_linspace', worst_case_doppler_precision_hz)) / 100;
            else
                results('doppler_precision') = 0;
            end

            %% Tx Power
            tx_power_w = double(separateUnits(unitConvert(obj.tx_power, u.W)));
            if tx_power_w <= specs.tx_power.goal.value
                results('tx_power') = 1;
            elseif tx_power_w <= specs.tx_power.required.value
                tmp_txpwr_linspace = linspace(double(specs.tx_power.required.value), double(specs.tx_power.goal.value));
                results('tx_power') = single(knnsearch(tmp_txpwr_linspace', tx_power_w)) / 100;
            else
                results('tx_power') = 0;
            end

            %% Swath Width
            swath_width_km = double(separateUnits(unitConvert(obj.swath_width, u.km)));
            if swath_width_km >= specs.swath_width.goal.value
                results('swath_width') = 1;
            elseif swath_width_km >= specs.swath_width.required.value
                tmp_swathw_linspace = linspace(double(specs.swath_width.required.value), double(specs.swath_width.goal.value));
                results('swath_width') = single(knnsearch(tmp_swathw_linspace', swath_width_km)) / 100;
            else
                results('swath_width') = 0;
            end

            val = results;
        end
    end
end
