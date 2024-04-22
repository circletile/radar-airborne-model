% name:     Airborne Radar Model - "No Symbolic Units" Build
% matver:   R2023b
% summary:  Models UAV radar system as part of university coursework
% author:   Chris Upchurch (chrisu@ucf.edu)
% notes:    - This class object is primarily used for production work.
%           - The runtime is significantly improved over UAVRadarModel class objects,
%             as it has most (but not all) MATLAB symbolic unit usage removed.
%           - Wherever possible, use UAVRadarModel_NoSyms class objects
%             instead of UAVRadarModel class objects.
% warning:  - The removal of symunits also removes unit most conversion assurances
%             (by way of symunit conversion errors/halts). If you extend this model for your own 
%             purposes, PAY VERY CLOSE ATTENTION TO UNIT INPUTS/OUTPUTS FOR ALL FUNCTION CALLS.

classdef UAVRadarModel_NoSyms < handle
    %% Object Inputs
    properties
        rdr_mode_strategy

        ant_bs_grazing_ang_mid_deg {mustBeNumeric}
        ant_dim_elev_m {mustBeNumeric}
        ant_dim_azim_m {mustBeNumeric}
        ant_azim_fwd_look_half_angle_deg {mustBeNumeric}
        ant_spin_rate_rpm {mustBeNumeric}
        ant_altitude_km {mustBeNumeric}

        tx_freq_ghz {mustBeNumeric}
        tx_power_w {mustBeNumeric}
        tx_pulse_width_sec {mustBeNumeric}
        tx_prf_hz {mustBeNumeric}
        tx_pcr {mustBeNumeric}

        t_fa_sec {mustBeNumeric}
        scan_qty_on_tgt_intent {mustBeNumeric}
    end

    %% Private Property Defs

    properties (GetAccess = private, SetAccess = private)
        model_cache = configureDictionary("string", "double");
    end

    %% Dependent Property Defs

    properties (Dependent)
        % rx_clutter_pwr_db_far {isUnit}
        % rx_clutter_pwr_db_mid {isUnit}
        % rx_clutter_pwr_db_near {isUnit}
        scan_fov_overlap_pct {isUnit}
        ant_bs_grazing_ang_far_deg {isUnit}
        ant_bs_grazing_ang_near_deg {isUnit}
        ant_hpbw_azimuth_deg {isUnit}
        ant_hpbw_elevation_deg {isUnit}
        avg_tgt_xs_area_far_sq_m {isUnit}
        avg_tgt_xs_area_mid_sq_m {isUnit}
        avg_tgt_xs_area_near_sq_m {isUnit}
        bs_rng_far_km {isUnit}
        bs_rng_mid_km {isUnit}
        bs_rng_near_km {isUnit}
        clutter_eff_area_far_sq_m {isUnit}
        clutter_eff_area_mid_sq_m {isUnit}
        clutter_eff_area_near_sq_m {isUnit}
        clutter_sigma0_db_far {mustBeNumeric}
        clutter_sigma0_db_mid {mustBeNumeric}
        clutter_sigma0_db_near {mustBeNumeric}
        clutter_to_noise_db_far {mustBeNumeric}
        clutter_to_noise_db_mid {mustBeNumeric}
        clutter_to_noise_db_near {mustBeNumeric}
        doppler_precision_far_hz {mustBeNumeric}
        doppler_precision_mid_hz {mustBeNumeric}
        doppler_precision_near_hz {mustBeNumeric}
        doppler_time_on_target_sec {isUnit}
        fov_area_approx_sq_km {isUnit}
        fov_azimuth_km {isUnit}
        fov_range_km {isUnit}
        ifov_far_sq_m {isUnit}
        ifov_mid_sq_m {isUnit}
        ifov_near_sq_m {isUnit}
        l_atm_oneway_db_far {mustBeNumeric}
        l_atm_oneway_db_mid {mustBeNumeric}
        l_atm_oneway_db_near {mustBeNumeric}
        l_atm_roundtrip_db_far {mustBeNumeric}
        l_atm_roundtrip_db_mid {mustBeNumeric}
        l_atm_roundtrip_db_near {mustBeNumeric}
        max_expected_doppler_freq_far_hz {isUnit}
        max_expected_doppler_freq_mid_hz {isUnit}
        max_expected_doppler_freq_near_hz {isUnit}
        max_prf_supported_hz {isUnit}
        min_spin_rate_supported_rpm {mustBeNumeric}
        nyquist_reqd_for_max_doppler_far_hz {isUnit}
        nyquist_reqd_for_max_doppler_mid_hz {isUnit}
        nyquist_reqd_for_max_doppler_near_hz {isUnit}
        pulses_on_target {mustBeNumeric}
        pulse_azim_res_far_m {isUnit}
        pulse_azim_res_mid_m {isUnit}
        pulse_azim_res_near_m {isUnit}
        pulse_rng_res_far_m {isUnit}
        pulse_rng_res_mid_m {isUnit}
        pulse_rng_res_near_m {isUnit}
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
        rtt_far_sec {isUnit}
        rtt_mid_sec {isUnit}
        rtt_near_sec {isUnit}
        rx_minus3dB_bw_predet {isUnit}
        rx_noise_power {isUnit}
        rx_noise_power_db {mustBeNumeric}
        rx_single_pulse_pwr_db_far {mustBeNumeric}
        rx_single_pulse_pwr_db_mid {mustBeNumeric}
        rx_single_pulse_pwr_db_near {mustBeNumeric}
        rx_single_pulse_pwr_far {isUnit}
        rx_single_pulse_pwr_mid {isUnit}
        rx_single_pulse_pwr_near {isUnit}
        swath_width_km {isUnit}
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
        time_on_target_sec {isUnit}
        tx_ant_gain {mustBeNumeric}
        tx_ant_gain_db {mustBeNumeric}
        tx_duty_cycle {isUnit}
        t_spin_sec {isUnit}
        t_sys_k {isUnit}
        t_warn_sec {isUnit}
        worst_case_doppler_precision_hz {mustBeNumeric}
        worst_case_max_expected_doppler_freq_hz {isUnit}
        worst_case_nyquist_reqd_for_max_doppler_hz {isUnit}
        worst_case_p_det_multi_pulse {mustBeNumeric}
        worst_case_pulse_rng_res_m {isUnit}
        worst_case_pulse_azim_res_m {isUnit}
        requirements_check
        goals_check
        worst_case_p_det_n_of_m {isnumeric}
        worst_case_tgt_to_clutter_noise_noncoh_multi_db {isnumeric}
    end

    %% Constants

    properties (Constant)
        const_ant_tref_degk = 290;

        const_nofm_det_qty = 2;
        const_nofm_total_qty = 4;

        % SYMUNIT_OK_TO_KEEP
        const_fwd_look_half_ang_max_deg = 90 * symunit('deg');

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

        const_ac_gnd_speed_kmh = 115;
        const_tgt_speed_max_kmh = 200;
        const_tgt_speed_min_kmh = 50;

        const_ant_rpm_max = 180;

        const_latm_37g_1way_dbkm = -0.05;
        const_latm_90g_1way_dbkm = -0.2;
        const_latm_150g_1way_dbkm = -0.6;
        const_latm_eff_max_altitude_km = 5;

        const_tsys_37g_degk = 500;
        const_tsys_90g_degk = 700;
        const_tsys_150g_degk = 1000;

        const_requirements_json_file = 'data\customer_requirements.json'
    end

    %% Static Functions

    methods (Static)
        function val = ratio2db(ratio)
            val = 10 * log10(ratio);
        end

        function val = db2ratio(db)
            if isUnit(db)
                error('Function input db must not be a symbolic unit.')
            end
            val = 10 ^ (db / 10);
        end

        function val = freq2wavelen(freq_hz)
            val = physconst('LightSpeed') / freq_hz;
        end

        function val = boltzmann_const_j_per_degk()
            val = physconst('Boltzmann');
        end

        function val = spd_of_light_m_per_sec()
            % SYMUNIT_OK_TO_KEEP
            val = physconst('LightSpeed');
        end

        function val = doppler_freq_hz(vel_radial_m_per_sec, wavelen)
            val = (2 * vel_radial_m_per_sec / wavelen);
        end
    end

    %% Dynamic Functions

    methods
        %% Constructor
        function obj = UAVRadarModel_NoSyms(rdr_mode_strategy, opts)
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
                opts.scan_qty_on_tgt_intent (1, 1) uint16
            end

            % SYMUNIT_OK_TO_KEEP
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
            obj.ant_bs_grazing_ang_mid_deg = double(separateUnits(unitConvert(opts.ant_bs_grazing_ang_mid, u.deg)));
            obj.ant_dim_elev_m = double(separateUnits(unitConvert(opts.ant_dim_elev, u.m)));
            obj.ant_dim_azim_m = double(separateUnits(unitConvert(opts.ant_dim_azim, u.m)));
            obj.ant_azim_fwd_look_half_angle_deg = double(separateUnits(unitConvert(opts.ant_azim_fwd_look_half_angle, u.deg)));
            obj.ant_spin_rate_rpm = double(separateUnits(unitConvert(opts.ant_spin_rate, u.rpm)));
            obj.ant_altitude_km = double(separateUnits(unitConvert(opts.ant_altitude, u.km)));
            obj.tx_freq_ghz = double(separateUnits(unitConvert(opts.tx_freq, u.GHz)));
            obj.tx_power_w = double(separateUnits(unitConvert(opts.tx_power, u.W)));
            obj.tx_pulse_width_sec = double(separateUnits(unitConvert(opts.tx_pulse_width, u.sec)));
            obj.tx_prf_hz = double(separateUnits(unitConvert(opts.tx_prf, u.Hz)));
            obj.tx_pcr = opts.tx_pcr;
            obj.t_fa_sec = double(separateUnits(unitConvert(opts.t_fa, u.sec)));
            obj.scan_qty_on_tgt_intent = opts.scan_qty_on_tgt_intent;
        end

        %% Property Set Functions

        function set.rdr_mode_strategy(obj, val)
            obj.rdr_mode_strategy = val;
            obj.purge_model_cache;
        end

        function set.ant_bs_grazing_ang_mid_deg(obj, val)
            % SYMUNIT_OK_TO_KEEP
            u = symunit;
            if isUnit(val)
                obj.ant_bs_grazing_ang_mid_deg = double(separateUnits(unitConvert(val, u.deg)));
            else
                obj.ant_bs_grazing_ang_mid_deg = val;
            end
            obj.purge_model_cache;
        end

        function set.ant_dim_elev_m(obj, val)
            % SYMUNIT_OK_TO_KEEP
            if isUnit(val)
                obj.ant_dim_elev_m = double(separateUnits(unitConvert(val, u.m)));
            else
                obj.ant_dim_elev_m = val;
            end
            obj.purge_model_cache;
        end

        function set.ant_dim_azim_m(obj, val)
            % SYMUNIT_OK_TO_KEEP
            if isUnit(val)
                obj.ant_dim_azim_m = double(separateUnits(unitConvert(val, u.m)));
            else
                obj.ant_dim_azim_m = val;
            end
            obj.purge_model_cache;
        end

        function set.ant_azim_fwd_look_half_angle_deg(obj, val)
            % SYMUNIT_OK_TO_KEEP
            if isUnit(val)
                obj.ant_azim_fwd_look_half_angle_deg = double(separateUnits(unitConvert(val, u.deg)));
            else
                obj.ant_azim_fwd_look_half_angle_deg = val;
            end
            obj.purge_model_cache;
        end

        function set.ant_spin_rate_rpm(obj, val)
            % SYMUNIT_OK_TO_KEEP
            if isUnit(val)
                obj.ant_spin_rate_rpm = double(separateUnits(unitConvert(val, u.rpm)));
            else
                obj.ant_spin_rate_rpm = val;
            end
            obj.purge_model_cache;
        end

        function set.ant_altitude_km(obj, val)
            % SYMUNIT_OK_TO_KEEP
            if isUnit(val)
                obj.ant_altitude_km = double(separateUnits(unitConvert(val, u.km)));
            else
                obj.ant_altitude_km = val;
            end
            obj.purge_model_cache;
        end

        function set.tx_freq_ghz(obj, val)
            % SYMUNIT_OK_TO_KEEP
            if isUnit(val)
                obj.tx_freq_ghz = double(separateUnits(unitConvert(val, u.GHz)));
            else
                obj.tx_freq_ghz = val;
            end
            obj.purge_model_cache;
        end

        function set.tx_power_w(obj, val)
            % SYMUNIT_OK_TO_KEEP
            if isUnit(val)
                obj.tx_power_w = double(separateUnits(unitConvert(val, u.W)));
            else
                obj.tx_power_w = val;
            end
            obj.purge_model_cache;
        end

        function set.tx_pulse_width_sec(obj, val)
            % SYMUNIT_OK_TO_KEEP
            if isUnit(val)
                obj.tx_pulse_width_sec = double(separateUnits(unitConvert(val, u.sec)));
            else
                obj.tx_pulse_width_sec = val;
            end
            obj.purge_model_cache;
        end

        function set.tx_prf_hz(obj, val)
            % SYMUNIT_OK_TO_KEEP
            if isUnit(val)
                obj.tx_prf_hz = double(separateUnits(unitConvert(val, u.Hz)));
            else
                obj.tx_prf_hz = val;
            end
            obj.purge_model_cache;
        end

        function set.tx_pcr(obj, val)
            obj.tx_pcr = val;
            obj.purge_model_cache;
        end

        function set.t_fa_sec(obj, val)
            % SYMUNIT_OK_TO_KEEP
            if isUnit(val)
                obj.t_fa_sec = double(separateUnits(unitConvert(val, u.sec)));
            else
                obj.t_fa_sec = val;
            end
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
            diag_idx = 1;
            diag_out = cell(60, 3);

            diag_out(diag_idx, :) = {'Range BS - Near', obj.bs_rng_near_km, 'km'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Range BS - Mid', obj.bs_rng_mid_km, 'km'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Range BS - Far', obj.bs_rng_far_km, 'km'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Pulse Range Rez - Near', obj.pulse_rng_res_near_m, 'm'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Pulse Range Rez - Mid', obj.pulse_rng_res_mid_m, 'm'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Pulse Range Rez - Far', obj.pulse_rng_res_far_m, 'm'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Pulse Azimuth Rez - Near', obj.pulse_azim_res_near_m, 'm'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Pulse Azimuth Rez - Mid', obj.pulse_azim_res_mid_m, 'm'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Pulse Azimuth Rez - Far', obj.pulse_azim_res_far_m, 'm'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Pulse IFOV - Near', obj.ifov_near_sq_m, 'm^2'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Pulse IFOV - Mid', obj.ifov_mid_sq_m, 'm^2'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Pulse IFOV - Far', obj.ifov_far_sq_m, 'm^2'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'BS Tgt. Xsect. - Near', obj.avg_tgt_xs_area_near_sq_m, 'm^2'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'BS Tgt. Xsect. - Mid', obj.avg_tgt_xs_area_mid_sq_m, 'm^2'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'BS Tgt. Xsect. - Far', obj.avg_tgt_xs_area_far_sq_m, 'm^2'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Clutter Eff. Xsect. - Near', obj.clutter_eff_area_near_sq_m, 'm^2'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Clutter Eff. Xsect. - Mid', obj.clutter_eff_area_mid_sq_m, 'm^2'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Clutter Eff. Xsect. - Far', obj.clutter_eff_area_far_sq_m, 'm^2'};
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

            diag_out(diag_idx, :) = {'TOT', obj.time_on_target_sec, 'sec'};
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

            diag_out(diag_idx, :) = {'Doppler Precision W/C - Near', obj.doppler_precision_near_hz, 'Hz'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Doppler Precision W/C - Mid', obj.doppler_precision_mid_hz, 'Hz'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Doppler Precision W/C - Far', obj.doppler_precision_far_hz, 'Hz'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Nyquist Reqd. for Doppler Max - Near', obj.nyquist_reqd_for_max_doppler_near_hz, 'Hz'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Nyquist Reqd. for Doppler Max - Mid', obj.nyquist_reqd_for_max_doppler_mid_hz, 'Hz'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Nyquist Reqd. for Doppler Max - Far', obj.nyquist_reqd_for_max_doppler_far_hz, 'Hz'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Ant. FP. Length', obj.fov_range_km, 'km'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Ant. Scan Overlap', obj.scan_fov_overlap_pct, 'pct'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'B_elev', obj.ant_hpbw_elevation_deg, 'deg'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'B_azim', obj.ant_hpbw_azimuth_deg, 'deg'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Radar Xfactor - Near', double(obj.ratio2db(obj.rdr_xfactor_near)), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Radar Xfactor - Mid', double(obj.ratio2db(obj.rdr_xfactor_mid)), 'dB'};
            diag_idx = diag_idx + 1;

            diag_out(diag_idx, :) = {'Radar Xfactor - Far', double(obj.ratio2db(obj.rdr_xfactor_far)), 'dB'};

            val = diag_out;
        end

        function val = dump_eval_outputs(obj)
            eval_idx = 1;
            eval_out = cell(60, 3);

            eval_out(eval_idx, :) = {'Swath Width', obj.swath_width_km, 'km'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'[IN] Tx Pulse Width', obj.tx_pulse_width_sec, 'sec'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'[IN] Ant Size Azimuth', obj.ant_dim_azim_m, 'm'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'[IN] Ant. Size Elevation', obj.ant_dim_elev_m, 'm'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'Min. Grazing Angle', obj.ant_bs_grazing_ang_near_deg, 'deg'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'Max PRF Supported', obj.max_prf_supported_hz, 'Hz'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'[IN] Selected PRF', obj.tx_prf_hz, 'Hz'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'T_spin / T_fa', obj.tfa_tspin_ratio, 'spins/fa'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'[IN] Ant. Spin Rate', obj.ant_spin_rate_rpm, 'rpm'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'[IN] Design Scan Qty. on Tgt.', obj.scan_qty_on_tgt_intent, 'scans'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'Min. Spin Rate Supported', obj.min_spin_rate_supported_rpm, 'rpm'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'Worst Case T_warn', obj.t_warn_sec, 'sec'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'Tx Duty Cycle', obj.tx_duty_cycle, 'sec'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'BS Range Resolution (far?)', obj.pulse_rng_res_far_m, 'm'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'BS Azimuth Resolution (far?)', obj.pulse_azim_res_far_m, 'm'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'P_det - Near', obj.p_det_multi_pulse_near, 'ratio'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'P_det - Mid', obj.p_det_multi_pulse_mid, 'ratio'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'P_det - Far', obj.p_det_multi_pulse_far, 'ratio'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'Doppler TOT (incl. design scan qty.)', obj.doppler_time_on_target_sec, 'sec'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'Nyquist PRF for Doppler Meas.', obj.worst_case_nyquist_reqd_for_max_doppler_hz, 'Hz'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'Max Reqd. Doppler Freq.', obj.worst_case_max_expected_doppler_freq_hz, 'Hz'};
            eval_idx = eval_idx + 1;

            eval_out(eval_idx, :) = {'Worst Case Doppler Precision', obj.worst_case_doppler_precision_hz, 'Hz'};
            % eval_idx = eval_idx + 1;

            val = eval_out;
        end

        function val = dump_doppler_diags(obj)
            dplr_idx = 1;
            dplr_out = cell(60, 3);

            [case_1c_delta, case_1c_total] = obj.doppler_case1_center;
            [case_1e_delta, case_1e_total] = obj.doppler_case1_edge;
            [case_2c_delta, case_2c_total] = obj.doppler_case2_center;
            [case_2e_delta, case_2e_total] = obj.doppler_case2_edge;
            [case_3cp_delta, case_3cp_total] = obj.doppler_case3_center_plus;
            [case_3cm_delta, case_3cm_total] = obj.doppler_case3_center_minus;
            [case_3ep_delta, case_3ep_total] = obj.doppler_case3_edge_plus;
            [case_3em_delta, case_3em_total] = obj.doppler_case3_edge_minus;
            [case_4c_delta, case_4c_total] = obj.doppler_case4_center;

            % Case1
            dplr_out(dplr_idx, :) = {'Case1 | Center | Delta', case_1c_delta / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;
            dplr_out(dplr_idx, :) = {'Case1 | Center | Total', case_1c_total / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;

            dplr_out(dplr_idx, :) = {'Case1 | Edge | Delta', case_1e_delta / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;
            dplr_out(dplr_idx, :) = {'Case1 | Edge | Total', case_1e_total / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;

            % Case2
            dplr_out(dplr_idx, :) = {'Case2 | Center | Delta', case_2c_delta / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;
            dplr_out(dplr_idx, :) = {'Case2 | Center | Total', case_2c_total / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;

            dplr_out(dplr_idx, :) = {'Case2 | Edge | Delta', case_2e_delta / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;
            dplr_out(dplr_idx, :) = {'Case2 | Edge | Total', case_2e_total / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;

            % Case3
            dplr_out(dplr_idx, :) = {'Case3 | Center+ | Delta', case_3cp_delta / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;
            dplr_out(dplr_idx, :) = {'Case3 | Center+ | Total', case_3cp_total / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;

            dplr_out(dplr_idx, :) = {'Case3 | Center- | Delta', case_3cm_delta / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;
            dplr_out(dplr_idx, :) = {'Case3 | Center- | Total', case_3cm_total / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;

            dplr_out(dplr_idx, :) = {'Case3 | Edge+ | Delta', case_3ep_delta / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;
            dplr_out(dplr_idx, :) = {'Case3 | Edge+ | Total', case_3ep_total / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;

            dplr_out(dplr_idx, :) = {'Case3 | Edge- | Delta', case_3em_delta / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;
            dplr_out(dplr_idx, :) = {'Case3 | Edge- | Total', case_3em_total / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;

            % Case4
            dplr_out(dplr_idx, :) = {'Case4 | Center | Delta', case_4c_delta / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;
            dplr_out(dplr_idx, :) = {'Case4 | Center | Total', case_4c_total / 1000, 'kHz'};
            dplr_idx = dplr_idx + 1;

            wc_delta_hz = min([abs(case_1c_delta), abs(case_1e_delta), ...
                                   abs(case_2c_delta), abs(case_2e_delta), ...
                                   abs(case_3cp_delta), abs(case_3cm_delta), ...
                                   abs(case_3ep_delta), abs(case_3em_delta), ...
                                   abs(case_4c_delta)]);

            wc_total_hz = max([abs(case_1c_total), abs(case_1e_total), ...
                                   abs(case_2c_total), abs(case_2e_total), ...
                                   abs(case_3cp_total), abs(case_3cm_total), ...
                                   abs(case_3ep_total), abs(case_3em_total), ...
                                   abs(case_4c_total)]);

            if (2 * obj.worst_case_doppler_precision_hz) >= wc_delta_hz
                dplr_out(dplr_idx, :) = {'Min Delta Supported by Dplr. Prcsn.', 0, 'bool'};
            else
                dplr_out(dplr_idx, :) = {'Min Delta Supported by Dplr. Prcsn.', 1, 'bool'};
            end
            dplr_idx = dplr_idx + 1;

            if obj.tx_prf_hz >= 2 * wc_total_hz
                dplr_out(dplr_idx, :) = {'Max Total Supported by PRF', 1, 'bool'};
            else
                dplr_out(dplr_idx, :) = {'Max Total Supported by PRF', 0, 'bool'};
            end

            val = dplr_out;
        end

        %% Dependent Property Functions

        function val = get.tx_duty_cycle(obj)
            if isKey(obj.model_cache, 'tx_duty_cycle')
                val = obj.model_cache('tx_duty_cycle');
            else
                ipp = 1 / obj.tx_prf_hz;
                func_result = obj.tx_pulse_width_sec / ipp;

                obj.model_cache('tx_duty_cycle') = func_result;
                val = func_result;
            end
        end

        function val = get.swath_width_km(obj)
            if isKey(obj.model_cache, 'swath_width')
                val = obj.model_cache('swath_width');
            else
                % warning('Using FAR range/grz_ang values instead of NEAR. DrJ eval sheet appears to use FAR. Need to confirm this.')
                % gnd_trk_rng_near = obj.bs_rng_near_km * cos(deg2rad(obj.ant_bs_grazing_ang_near_deg));
                gnd_trk_rng_far = obj.bs_rng_far_km * cos(deg2rad(obj.ant_bs_grazing_ang_far_deg));
                % func_result = 2 * (gnd_trk_rng_near * sin(deg2rad(obj.ant_azim_fwd_look_half_angle_deg)));
                func_result = 2 * (gnd_trk_rng_far * sin(deg2rad(obj.ant_azim_fwd_look_half_angle_deg)));

                obj.model_cache('swath_width') = func_result;
                val = func_result;
            end
        end

        function val = get.bs_rng_far_km(obj)
            if isKey(obj.model_cache, 'bs_rng_far')
                val = obj.model_cache('bs_rng_far');
            else
                inclination_ang_far = 90 - obj.ant_bs_grazing_ang_far_deg;
                func_result = obj.ant_altitude_km / cos(deg2rad(inclination_ang_far));

                obj.model_cache('bs_rng_far') = func_result;
                val = func_result;
            end
        end

        function val = get.bs_rng_near_km(obj)
            if isKey(obj.model_cache, 'bs_rng_near')
                val = obj.model_cache('bs_rng_near');
            else
                inclination_ang_near = 90 - obj.ant_bs_grazing_ang_near_deg;
                func_result = obj.ant_altitude_km / cos(deg2rad(inclination_ang_near));

                obj.model_cache('bs_rng_near') = func_result;
                val = func_result;
            end
        end

        function val = get.bs_rng_mid_km(obj)
            if isKey(obj.model_cache, 'bs_rng_mid')
                val = obj.model_cache('bs_rng_mid');
            else
                inclination_ang_mid = 90 - obj.ant_bs_grazing_ang_mid_deg;
                func_result = obj.ant_altitude_km / cos(deg2rad(inclination_ang_mid));

                obj.model_cache('bs_rng_mid') = func_result;
                val = func_result;
            end
        end

        function val = get.fov_range_km(obj)
            if isKey(obj.model_cache, 'fov_range')
                val = obj.model_cache('fov_range');
            else
                gnd_trk_rng_far = obj.bs_rng_far_km * cos(deg2rad(obj.ant_bs_grazing_ang_far_deg));
                gnd_trk_rng_near = obj.bs_rng_near_km * cos(deg2rad(obj.ant_bs_grazing_ang_near_deg));

                func_result = gnd_trk_rng_far - gnd_trk_rng_near;

                obj.model_cache('fov_range') = func_result;
                val = func_result;
            end
        end

        function val = get.fov_azimuth_km(obj)
            % NB: We just call pulse_azim_res_mid_m() here since it acts as the "most average" value
            %     If you're looking here for possible calculation issues, we probably need to provide
            %     azimuth FOV for near & far as well.
            val = obj.pulse_azim_res_mid_m / 1000;
        end

        function val = get.fov_area_approx_sq_km(obj)
            if isKey(obj.model_cache, 'fov_area_approx')
                val = obj.model_cache('fov_area_approx');
            else
                func_result = obj.fov_range_km * obj.fov_azimuth_km;

                obj.model_cache('fov_area_approx') = func_result;
                val = func_result;
            end
        end

        function val = get.t_spin_sec(obj)
            if isKey(obj.model_cache, 't_spin_sec')
                val = obj.model_cache('t_spin_sec');
            else
                func_result = 60 / obj.ant_spin_rate_rpm;

                obj.model_cache('t_spin_sec') = func_result;
                val = func_result;
            end
        end

        function val = get.tfa_tspin_ratio(obj)
            if isKey(obj.model_cache, 'tfa_tspin_ratio')
                val = obj.model_cache('tfa_tspin_ratio');
            else
                func_result = obj.t_fa_sec / obj.t_spin_sec;

                obj.model_cache('tfa_tspin_ratio') = func_result;
                val = func_result;
            end
        end

        function val = get.p_fa(obj)
            if isKey(obj.model_cache, 'p_fa')
                val = obj.model_cache('p_fa');
            else
                func_result = 1 / (obj.t_fa_sec * obj.rx_minus3dB_bw_predet);

                obj.model_cache('p_fa') = func_result;
                val = func_result;
            end
        end

        function val = get.rdr_xfactor_near(obj)
            if isKey(obj.model_cache, 'rdr_xfactor_near')
                val = obj.model_cache('rdr_xfactor_near');
            else
                % NB: For this model, the only Lsys component being considered is Latm_roundtrip
                local_lsys_db = obj.l_atm_roundtrip_db_near;

                func_result = obj.tx_power_w * ...
                    (obj.tx_ant_gain) ^ 2 * ...
                    (obj.freq2wavelen(obj.tx_freq_ghz * 1e+09) ^ 2) * ...
                    (1 / ((4 * pi) ^ 3)) * ...
                    obj.db2ratio(local_lsys_db);

                obj.model_cache('rdr_xfactor_near') = func_result;
                val = func_result;
            end
        end

        function val = get.rdr_xfactor_mid(obj)
            if isKey(obj.model_cache, 'rdr_xfactor_mid')
                val = obj.model_cache('rdr_xfactor_mid');
            else
                % NB: For this model, the only Lsys component being considered is Latm_roundtrip
                local_lsys_db = obj.l_atm_roundtrip_db_mid;

                func_result = obj.tx_power_w * ...
                    (obj.tx_ant_gain) ^ 2 * ...
                    (obj.freq2wavelen(obj.tx_freq_ghz * 1e+09) ^ 2) * ...
                    (1 / ((4 * pi) ^ 3)) * ...
                    obj.db2ratio(local_lsys_db);

                obj.model_cache('rdr_xfactor_mid') = func_result;
                val = func_result;
            end
        end

        function val = get.rdr_xfactor_far(obj)
            if isKey(obj.model_cache, 'rdr_xfactor_far')
                val = obj.model_cache('rdr_xfactor_far');
            else
                % NB: For this model, the only Lsys component being considered is Latm_roundtrip
                local_lsys_db = obj.l_atm_roundtrip_db_far;

                func_result = obj.tx_power_w * ...
                    (obj.tx_ant_gain) ^ 2 * ...
                    (obj.freq2wavelen(obj.tx_freq_ghz * 1e+09) ^ 2) * ...
                    (1 / ((4 * pi) ^ 3)) * ...
                    obj.db2ratio(local_lsys_db);

                obj.model_cache('rdr_xfactor_far') = func_result;
                val = func_result;
            end
        end

        function val = get.rx_single_pulse_pwr_near(obj)
            if isKey(obj.model_cache, 'rx_single_pulse_pwr_near')
                val = obj.model_cache('rx_single_pulse_pwr_near');
            else
                func_result = obj.rdr_xfactor_near * (obj.avg_tgt_xs_area_near_sq_m / ((1000 * obj.bs_rng_near_km) ^ 4));

                obj.model_cache('rx_single_pulse_pwr_near') = func_result;
                val = func_result;
            end
        end

        function val = get.rx_single_pulse_pwr_mid(obj)
            if isKey(obj.model_cache, 'rx_single_pulse_pwr_mid')
                val = obj.model_cache('rx_single_pulse_pwr_mid');
            else
                func_result = obj.rdr_xfactor_mid * (obj.avg_tgt_xs_area_mid_sq_m / ((1000 * obj.bs_rng_mid_km) ^ 4));

                obj.model_cache('rx_single_pulse_pwr_mid') = func_result;
                val = func_result;
            end
        end

        function val = get.rx_single_pulse_pwr_far(obj)
            if isKey(obj.model_cache, 'rx_single_pulse_pwr_far')
                val = obj.model_cache('rx_single_pulse_pwr_far');
            else
                func_result = obj.rdr_xfactor_far * (obj.avg_tgt_xs_area_far_sq_m / ((1000 * obj.bs_rng_far_km) ^ 4));

                obj.model_cache('rx_single_pulse_pwr_far') = func_result;
                val = func_result;
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
                func_result = obj.boltzmann_const_j_per_degk * obj.t_sys_k * obj.rx_minus3dB_bw_predet;

                obj.model_cache('rx_noise_power') = func_result;
                val = func_result;
            end
        end

        function val = get.rx_noise_power_db(obj)
            val = obj.ratio2db(obj.rx_noise_power);
        end

        function val = get.clutter_sigma0_db_near(obj)
            if isKey(obj.model_cache, 'clutter_sigma0_db_near')
                val = obj.model_cache('clutter_sigma0_db_near');
            else
                grz_angle_deg = obj.ant_bs_grazing_ang_near_deg;
                func_result = ((obj.const_clut_p1 * grz_angle_deg ^ 4) + (obj.const_clut_p2 * grz_angle_deg ^ 3) + ...
                    (obj.const_clut_p3 * grz_angle_deg ^ 2) + (obj.const_clut_p4 * grz_angle_deg) + obj.const_clut_p5);

                obj.model_cache('clutter_sigma0_db_near') = func_result;
                val = func_result;
            end
        end

        function val = get.clutter_sigma0_db_mid(obj)
            if isKey(obj.model_cache, 'clutter_sigma0_db_mid')
                val = obj.model_cache('clutter_sigma0_db_mid');
            else
                grz_angle_deg = obj.ant_bs_grazing_ang_mid_deg;
                func_result = ((obj.const_clut_p1 * grz_angle_deg ^ 4) + (obj.const_clut_p2 * grz_angle_deg ^ 3) + ...
                    (obj.const_clut_p3 * grz_angle_deg ^ 2) + (obj.const_clut_p4 * grz_angle_deg) + obj.const_clut_p5);

                obj.model_cache('clutter_sigma0_db_mid') = func_result;
                val = func_result;
            end
        end

        function val = get.clutter_sigma0_db_far(obj)
            if isKey(obj.model_cache, 'clutter_sigma0_db_far')
                val = obj.model_cache('clutter_sigma0_db_far');
            else
                grz_angle_deg = obj.ant_bs_grazing_ang_far_deg;
                func_result = ((obj.const_clut_p1 * grz_angle_deg ^ 4) + (obj.const_clut_p2 * grz_angle_deg ^ 3) + ...
                    (obj.const_clut_p3 * grz_angle_deg ^ 2) + (obj.const_clut_p4 * grz_angle_deg) + obj.const_clut_p5);

                obj.model_cache('clutter_sigma0_db_far') = func_result;
                val = func_result;
            end
        end

        function val = get.clutter_eff_area_near_sq_m(obj)
            if isKey(obj.model_cache, 'clutter_eff_area_near_sq_m')
                val = obj.model_cache('clutter_eff_area_near_sq_m');
            else
                func_result = obj.db2ratio(obj.clutter_sigma0_db_near) * obj.ifov_near_sq_m;

                obj.model_cache('clutter_eff_area_near_sq_m') = func_result;
                val = func_result;
            end
        end

        function val = get.clutter_eff_area_mid_sq_m(obj)
            if isKey(obj.model_cache, 'clutter_eff_area_mid_sq_m')
                val = obj.model_cache('clutter_eff_area_mid_sq_m');
            else
                func_result = obj.db2ratio(obj.clutter_sigma0_db_mid) * obj.ifov_mid_sq_m;

                obj.model_cache('clutter_eff_area_mid_sq_m') = func_result;
                val = func_result;
            end
        end

        function val = get.clutter_eff_area_far_sq_m(obj)
            if isKey(obj.model_cache, 'clutter_eff_area_far_sq_m')
                val = obj.model_cache('clutter_eff_area_far_sq_m');
            else
                func_result = obj.db2ratio(obj.clutter_sigma0_db_far) * obj.ifov_far_sq_m;

                obj.model_cache('clutter_eff_area_far_sq_m') = func_result;
                val = func_result;
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
                func_result = obj.ratio2db(obj.avg_tgt_xs_area_near_sq_m / obj.clutter_eff_area_near_sq_m);
                obj.model_cache('tgt_to_clutter_db_near') = func_result;
                val = func_result;
            end
        end

        function val = get.tgt_to_clutter_db_mid(obj)
            if isKey(obj.model_cache, 'tgt_to_clutter_db_mid')
                val = obj.model_cache('tgt_to_clutter_db_mid');
            else
                func_result = obj.ratio2db(obj.avg_tgt_xs_area_mid_sq_m / obj.clutter_eff_area_mid_sq_m);
                obj.model_cache('tgt_to_clutter_db_mid') = func_result;
                val = func_result;
            end
        end

        function val = get.tgt_to_clutter_db_far(obj)
            if isKey(obj.model_cache, 'tgt_to_clutter_db_far')
                val = obj.model_cache('tgt_to_clutter_db_far');
            else
                func_result = obj.ratio2db(obj.avg_tgt_xs_area_far_sq_m / obj.clutter_eff_area_far_sq_m);
                obj.model_cache('tgt_to_clutter_db_far') = func_result;
                val = func_result;
            end
        end

        function val = get.tgt_to_noise_db_near(obj)
            if isKey(obj.model_cache, 'tgt_to_noise_db_near')
                val = obj.model_cache('tgt_to_noise_db_near');
            else
                func_result = obj.rx_single_pulse_pwr_db_near - obj.rx_noise_power_db;
                obj.model_cache('tgt_to_noise_db_near') = func_result;
                val = func_result;
            end
        end

        function val = get.tgt_to_noise_db_mid(obj)
            if isKey(obj.model_cache, 'tgt_to_noise_db_mid')
                val = obj.model_cache('tgt_to_noise_db_mid');
            else
                func_result = obj.rx_single_pulse_pwr_db_mid - obj.rx_noise_power_db;
                obj.model_cache('tgt_to_noise_db_mid') = func_result;
                val = func_result;
            end
        end

        function val = get.tgt_to_noise_db_far(obj)
            if isKey(obj.model_cache, 'tgt_to_noise_db_far')
                val = obj.model_cache('tgt_to_noise_db_far');
            else
                func_result = obj.rx_single_pulse_pwr_db_far - obj.rx_noise_power_db;
                obj.model_cache('tgt_to_noise_db_far') = func_result;
                val = func_result;
            end
        end

        function val = get.clutter_to_noise_db_near(obj)
            if isKey(obj.model_cache, 'clutter_to_noise_db_near')
                val = obj.model_cache('clutter_to_noise_db_near');
            else
                clutter_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_clutter_db_near);
                clutter_to_noise_ratio = clutter_to_tgt_ratio * obj.db2ratio(obj.tgt_to_noise_db_near);
                func_result = obj.ratio2db(clutter_to_noise_ratio);

                obj.model_cache('clutter_to_noise_db_near') = func_result;
                val = func_result;
            end
        end

        function val = get.clutter_to_noise_db_mid(obj)
            if isKey(obj.model_cache, 'clutter_to_noise_db_mid')
                val = obj.model_cache('clutter_to_noise_db_mid');
            else
                clutter_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_clutter_db_mid);
                clutter_to_noise_ratio = clutter_to_tgt_ratio * obj.db2ratio(obj.tgt_to_noise_db_mid);
                func_result = obj.ratio2db(clutter_to_noise_ratio);

                obj.model_cache('clutter_to_noise_db_mid') = func_result;
                val = func_result;
            end
        end

        function val = get.clutter_to_noise_db_far(obj)
            if isKey(obj.model_cache, 'clutter_to_noise_db_far')
                val = obj.model_cache('clutter_to_noise_db_far');
            else
                clutter_to_tgt_ratio = 1 / obj.db2ratio(obj.tgt_to_clutter_db_far);
                clutter_to_noise_ratio = clutter_to_tgt_ratio * obj.db2ratio(obj.tgt_to_noise_db_far);
                func_result = obj.ratio2db(clutter_to_noise_ratio);

                obj.model_cache('clutter_to_noise_db_far') = func_result;
                val = func_result;
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

                obj.model_cache('tgt_to_clutter_noise_db_near') = func_result;
                val = func_result;
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

                obj.model_cache('tgt_to_clutter_noise_db_mid') = func_result;
                val = func_result;
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

                obj.model_cache('tgt_to_clutter_noise_db_far') = func_result;
                val = func_result;
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

                % if imag(func_result) > 1e-6
                %     error('Complex/imaginary part of calculation result is nontrivial. Unable to continue.')
                % end

                % func_result = double(real(func_result));

                if func_result < 0 && func_result > 1
                    error('Calculation result for one or more values are out of bounds.')
                end

                obj.model_cache('p_det_single_pulse_near') = func_result;
                val = func_result;
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

                func_result = solve(eqn_near, p_det);

                if func_result < 0 && func_result > 1
                    error('Calculation result for one or more values are out of bounds.')
                end

                obj.model_cache('p_det_single_pulse_mid') = func_result;
                val = func_result;
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

                func_result = solve(eqn_near, p_det);

                if func_result < 0 && func_result > 1
                    error('Calculation result for one or more values are out of bounds.')
                end

                obj.model_cache('p_det_single_pulse_far') = func_result;
                val = func_result;
            end
        end

        function val = get.p_det_multi_pulse_near(obj)
            if isKey(obj.model_cache, 'p_det_multi_pulse_near')
                val = obj.model_cache('p_det_multi_pulse_near');
            else
                % Ref: '03_L-3B Radar_pulse_integ_POMR-revW_web.pdf' slide 62
                a_factor = log(0.62 / obj.p_fa);
                epsilon_factor = 1 / (0.62 + (0.454 / sqrt(obj.pulses_on_target + 0.44)));
                chi_factor = (obj.db2ratio(obj.tgt_to_clutter_noise_db_near) * sqrt(obj.pulses_on_target)) ^ epsilon_factor;
                beta_factor = (chi_factor - a_factor) / (0.12 * a_factor + 1.7);

                func_result = exp(beta_factor) / (1 + exp(beta_factor));

                obj.model_cache('p_det_multi_pulse_near') = func_result;
                val = func_result;
            end
        end

        function val = get.p_det_multi_pulse_mid(obj)
            if isKey(obj.model_cache, 'p_det_multi_pulse_mid')
                val = obj.model_cache('p_det_multi_pulse_mid');
            else
                % Ref: '03_L-3B Radar_pulse_integ_POMR-revW_web.pdf' slide 62
                a_factor = log(0.62 / obj.p_fa);
                epsilon_factor = 1 / (0.62 + (0.454 / sqrt(obj.pulses_on_target + 0.44)));
                chi_factor = (obj.db2ratio(obj.tgt_to_clutter_noise_db_mid) * sqrt(obj.pulses_on_target)) ^ epsilon_factor;
                beta_factor = (chi_factor - a_factor) / (0.12 * a_factor + 1.7);

                func_result = exp(beta_factor) / (1 + exp(beta_factor));

                obj.model_cache('p_det_multi_pulse_mid') = func_result;
                val = func_result;
            end
        end

        function val = get.p_det_multi_pulse_far(obj)
            if isKey(obj.model_cache, 'p_det_multi_pulse_far')
                val = obj.model_cache('p_det_multi_pulse_far');
            else
                % Ref: '03_L-3B Radar_pulse_integ_POMR-revW_web.pdf' slide 62
                a_factor = log(0.62 / obj.p_fa);
                epsilon_factor = 1 / (0.62 + (0.454 / sqrt(obj.pulses_on_target + 0.44)));
                chi_factor = (obj.db2ratio(obj.tgt_to_clutter_noise_db_far) * sqrt(obj.pulses_on_target)) ^ epsilon_factor;
                beta_factor = (chi_factor - a_factor) / (0.12 * a_factor + 1.7);

                func_result = exp(beta_factor) / (1 + exp(beta_factor));

                obj.model_cache('p_det_multi_pulse_far') = func_result;
                val = func_result;
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

                obj.model_cache('t2cn_noncoh_multi_db_near') = func_result;
                val = func_result;
            end
        end

        function val = get.tgt_to_clutter_noise_noncoh_multi_db_mid(obj)
            if isKey(obj.model_cache, 't2cn_noncoh_multi_db_mid')
                val = obj.model_cache('t2cn_noncoh_multi_db_mid');
            else
                func_result = obj.db2ratio((-5 * log10(obj.pulses_on_target)) + ...
                    (6.2 + (4.54 / sqrt(obj.pulses_on_target + 0.44))) * ...
                    (log10(obj.p_det_single_pulse_mid)));

                obj.model_cache('t2cn_noncoh_multi_db_mid') = func_result;
                val = func_result;
            end
        end

        function val = get.tgt_to_clutter_noise_noncoh_multi_db_far(obj)
            if isKey(obj.model_cache, 't2cn_noncoh_multi_db_far')
                val = obj.model_cache('t2cn_noncoh_multi_db_far');
            else
                func_result = obj.db2ratio((-5 * log10(obj.pulses_on_target)) + ...
                    (6.2 + (4.54 / sqrt(obj.pulses_on_target + 0.44))) * ...
                    (log10(obj.p_det_single_pulse_far)));

                obj.model_cache('t2cn_noncoh_multi_db_far') = func_result;
                val = func_result;
            end
        end

        function val = get.worst_case_tgt_to_clutter_noise_noncoh_multi_db(obj)
            val = min([obj.tgt_to_clutter_noise_noncoh_multi_db_near, ...
                           obj.tgt_to_clutter_noise_noncoh_multi_db_mid, ...
                           obj.tgt_to_clutter_noise_noncoh_multi_db_far]);
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

                obj.model_cache('p_det_n_of_m_near') = func_result;
                val = func_result;
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

                obj.model_cache('p_det_n_of_m_mid') = func_result;
                val = func_result;
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

                obj.model_cache('p_det_n_of_m_far') = func_result;
                val = func_result;
            end
        end

        function val = get.worst_case_p_det_n_of_m(obj)
            val = min([obj.p_det_n_of_m_near, obj.p_det_n_of_m_mid, obj.p_det_n_of_m_far]);
        end

        function val = get.t_warn_sec(obj)
            % warning('DrJ 20240312 Eval returned a T_warn of 0.0sec. Need more input checks to confirm validity of this function.')
            if isKey(obj.model_cache, 't_warn_sec')
                val = obj.model_cache('t_warn_sec');
            else
                % gnd_trk_rng_far_km = obj.bs_rng_far_km * cos(deg2rad(obj.ant_bs_grazing_ang_far_deg));
                % tot_rel_speed_km_per_sec = (obj.const_tgt_speed_max_kmh + obj.const_ac_gnd_speed_kmh) / (60 * 60);
                % func_result = gnd_trk_rng_far_km / tot_rel_speed_km_per_sec;
                
                gnd_trk_rng_near_km = obj.bs_rng_near_km * cos(deg2rad(obj.ant_bs_grazing_ang_near_deg));
                gnd_trk_rng_rel_scan_width_km = gnd_trk_rng_near_km * cosd(obj.ant_azim_fwd_look_half_angle_deg);
                tot_rel_speed_km_per_sec = (obj.const_tgt_speed_max_kmh + obj.const_ac_gnd_speed_kmh) / (60 * 60);

                func_result = gnd_trk_rng_rel_scan_width_km / tot_rel_speed_km_per_sec;

                obj.model_cache('t_warn_sec') = func_result;
                val = func_result;
            end
        end

        function val = get.doppler_precision_near_hz(obj)
            if isKey(obj.model_cache, 'doppler_precision_near_hz')
                val = obj.model_cache('doppler_precision_near_hz');
            else
                tau = obj.tx_pulse_width_sec;
                n_0 = obj.boltzmann_const_j_per_degk * obj.t_sys_k;
                tot_incl_all_scans_on_tgt = (double(obj.scan_qty_on_tgt_intent) * (obj.pulses_on_target - 1)) / obj.tx_prf_hz;

                func_result = 1 / (tot_incl_all_scans_on_tgt * sqrt(2 * ((obj.db2ratio(obj.rx_single_pulse_pwr_db_near)) * tau) / n_0));

                obj.model_cache('doppler_precision_near_hz') = func_result;
                val = func_result;
            end
        end

        function val = get.doppler_precision_mid_hz(obj)
            if isKey(obj.model_cache, 'doppler_precision_mid_hz')
                val = obj.model_cache('doppler_precision_mid_hz');
            else
                tau = obj.tx_pulse_width_sec;
                n_0 = obj.boltzmann_const_j_per_degk * obj.t_sys_k;
                tot_incl_all_scans_on_tgt = (double(obj.scan_qty_on_tgt_intent) * (obj.pulses_on_target - 1)) / obj.tx_prf_hz;

                func_result = 1 / (tot_incl_all_scans_on_tgt * sqrt(2 * ((obj.db2ratio(obj.rx_single_pulse_pwr_db_mid)) * tau) / n_0));

                obj.model_cache('doppler_precision_mid_hz') = func_result;
                val = func_result;
            end
        end

        function val = get.doppler_precision_far_hz(obj)
            if isKey(obj.model_cache, 'doppler_precision_far_hz')
                val = obj.model_cache('doppler_precision_far_hz');
            else
                tau = obj.tx_pulse_width_sec;
                n_0 = obj.boltzmann_const_j_per_degk * obj.t_sys_k;
                tot_incl_all_scans_on_tgt = (double(obj.scan_qty_on_tgt_intent) * (obj.pulses_on_target - 1)) / obj.tx_prf_hz;

                func_result = 1 / (tot_incl_all_scans_on_tgt * sqrt(2 * ((obj.db2ratio(obj.rx_single_pulse_pwr_db_far)) * tau) / n_0));

                obj.model_cache('doppler_precision_far_hz') = func_result;
                val = func_result;
            end
        end

        function val = get.worst_case_doppler_precision_hz(obj)
            function_result = max([obj.doppler_precision_near_hz, ...
                                       obj.doppler_precision_mid_hz, ...
                                       obj.doppler_precision_far_hz]);

            val = function_result;
        end

        function val = get.nyquist_reqd_for_max_doppler_near_hz(obj)
            if isKey(obj.model_cache, 'nyquist_reqd_for_max_doppler_near_hz')
                val = obj.model_cache('nyquist_reqd_for_max_doppler_near_hz');
            else
                func_result = 2 * obj.max_expected_doppler_freq_near_hz;

                obj.model_cache('nyquist_reqd_for_max_doppler_near_hz') = func_result;
                val = func_result;
            end
        end

        function val = get.nyquist_reqd_for_max_doppler_mid_hz(obj)
            if isKey(obj.model_cache, 'nyquist_reqd_for_max_doppler_mid_hz')
                val = obj.model_cache('nyquist_reqd_for_max_doppler_mid_hz');
            else
                func_result = 2 * obj.max_expected_doppler_freq_mid_hz;

                obj.model_cache('nyquist_reqd_for_max_doppler_mid_hz') = func_result;
                val = func_result;
            end
        end

        function val = get.nyquist_reqd_for_max_doppler_far_hz(obj)
            if isKey(obj.model_cache, 'nyquist_reqd_for_max_doppler_far_hz')
                val = obj.model_cache('nyquist_reqd_for_max_doppler_far_hz');
            else
                func_result = 2 * obj.max_expected_doppler_freq_far_hz;

                obj.model_cache('nyquist_reqd_for_max_doppler_far_hz') = func_result;
                val = func_result;
            end
        end

        function val = get.worst_case_nyquist_reqd_for_max_doppler_hz(obj)
            function_result = max([obj.nyquist_reqd_for_max_doppler_near_hz, ...
                                       obj.nyquist_reqd_for_max_doppler_mid_hz, ...
                                       obj.nyquist_reqd_for_max_doppler_far_hz]);

            val = function_result;
        end

        function val = get.ant_bs_grazing_ang_far_deg(obj)
            if isKey(obj.model_cache, 'ant_bs_grazing_ang_far')
                val = obj.model_cache('ant_bs_grazing_ang_far');
            else
                inclination_ang_mid_deg = 90 - obj.ant_bs_grazing_ang_mid_deg;
                inclination_ang_far_deg = inclination_ang_mid_deg + (obj.ant_hpbw_elevation_deg / 2);
                func_result = 90 - inclination_ang_far_deg;

                obj.model_cache('ant_bs_grazing_ang_far') = func_result;
                val = func_result;
            end
        end

        function val = get.ant_bs_grazing_ang_near_deg(obj)
            if isKey(obj.model_cache, 'ant_bs_grazing_ang_near')
                val = obj.model_cache('ant_bs_grazing_ang_near');
            else
                inclination_ang_mid = 90 - obj.ant_bs_grazing_ang_mid_deg;
                inclination_ang_near = inclination_ang_mid - (obj.ant_hpbw_elevation_deg / 2);
                func_result = 90 - inclination_ang_near;

                obj.model_cache('ant_bs_grazing_ang_near') = func_result;
                val = func_result;
            end
        end

        function val = get.avg_tgt_xs_area_near_sq_m(obj)
            if isKey(obj.model_cache, 'avg_tgt_xs_area_near_sq_m')
                val = obj.model_cache('avg_tgt_xs_area_near_sq_m');
            else
                grz_ang_deg = obj.ant_bs_grazing_ang_near_deg;

                func_result = ((obj.const_rcs_p1 * grz_ang_deg ^ 4) + (obj.const_rcs_p2 * grz_ang_deg ^ 3) + ...
                    (obj.const_rcs_p3 * grz_ang_deg ^ 2) + (obj.const_rcs_p4 * grz_ang_deg) + obj.const_rcs_p5);

                obj.model_cache('avg_tgt_xs_area_near_sq_m') = func_result;
                val = func_result;
            end
        end

        function val = get.avg_tgt_xs_area_mid_sq_m(obj)
            if isKey(obj.model_cache, 'avg_tgt_xs_area_mid_sq_m')
                val = obj.model_cache('avg_tgt_xs_area_mid_sq_m');
            else
                grz_ang_deg = obj.ant_bs_grazing_ang_mid_deg;

                func_result = ((obj.const_rcs_p1 * grz_ang_deg ^ 4) + (obj.const_rcs_p2 * grz_ang_deg ^ 3) + ...
                    (obj.const_rcs_p3 * grz_ang_deg ^ 2) + (obj.const_rcs_p4 * grz_ang_deg) + obj.const_rcs_p5);

                obj.model_cache('avg_tgt_xs_area_mid_sq_m') = func_result;
                val = func_result;
            end
        end

        function val = get.avg_tgt_xs_area_far_sq_m(obj)
            if isKey(obj.model_cache, 'avg_tgt_xs_area_far_sq_m')
                val = obj.model_cache('avg_tgt_xs_area_far_sq_m');
            else
                grz_ang_deg = obj.ant_bs_grazing_ang_far_deg;

                func_result = ((obj.const_rcs_p1 * grz_ang_deg ^ 4) + (obj.const_rcs_p2 * grz_ang_deg ^ 3) + ...
                    (obj.const_rcs_p3 * grz_ang_deg ^ 2) + (obj.const_rcs_p4 * grz_ang_deg) + obj.const_rcs_p5);

                obj.model_cache('avg_tgt_xs_area_far_sq_m') = func_result;
                val = func_result;
            end
        end

        function val = get.t_sys_k(obj)
            freq_ghz = obj.tx_freq_ghz;
            if freq_ghz == 37
                val = obj.const_tsys_37g_degk;
            elseif freq_ghz == 90
                val = obj.const_tsys_90g_degk;
            elseif freq_ghz == 150
                val = obj.const_tsys_150g_degk;
            else
                error('Function input "obj.tx_freq_ghz" must be one of "37GHz", "90GHz", or "150GHz".')
            end
        end

        function val = get.l_atm_oneway_db_near(obj)
            if isKey(obj.model_cache, 'l_atm_oneway_db_near')
                val = obj.model_cache('l_atm_oneway_db_near');
            else
                freq_ghz = obj.tx_freq_ghz;

                if freq_ghz == 37
                    db_loss_factor = obj.const_latm_37g_1way_dbkm;
                elseif freq_ghz == 90
                    db_loss_factor = obj.const_latm_90g_1way_dbkm;
                elseif freq_ghz == 150
                    db_loss_factor = obj.const_latm_150g_1way_dbkm;
                else
                    error('Function input "obj.tx_freq_ghz" must be one of "37GHz", "90GHz", or "150GHz".')
                end

                % Get bs dist affected by latm
                bs_rng_affected_by_latm_km = obj.const_latm_eff_max_altitude_km / sin(deg2rad(obj.ant_bs_grazing_ang_near_deg));

                % NB: The following shouldn't ever happen due to aircraft alt minimums, but check for this situation anyway
                if obj.bs_rng_near_km < bs_rng_affected_by_latm_km
                    bs_rng_affected_by_latm_km = obj.bs_rng_near_km;
                end

                % Calc loss over the affected bs rng
                func_result = db_loss_factor * bs_rng_affected_by_latm_km;

                obj.model_cache('l_atm_oneway_db_near') = func_result;
                val = func_result;
            end
        end

        function val = get.l_atm_oneway_db_mid(obj)
            if isKey(obj.model_cache, 'l_atm_oneway_db_mid')
                val = obj.model_cache('l_atm_oneway_db_mid');
            else
                freq_ghz = obj.tx_freq_ghz;

                if freq_ghz == 37
                    db_loss_factor = obj.const_latm_37g_1way_dbkm;
                elseif freq_ghz == 90
                    db_loss_factor = obj.const_latm_90g_1way_dbkm;
                elseif freq_ghz == 150
                    db_loss_factor = obj.const_latm_150g_1way_dbkm;
                else
                    error('Function input "obj.tx_freq_ghz" must be one of "37GHz", "90GHz", or "150GHz".')
                end

                % Get bs dist affected by latm
                bs_rng_affected_by_latm_km = obj.const_latm_eff_max_altitude_km / sin(deg2rad(obj.ant_bs_grazing_ang_mid_deg));

                % NB: The following shouldn't ever happen due to aircraft alt minimums, but check for this situation anyway
                if obj.bs_rng_mid_km < bs_rng_affected_by_latm_km
                    bs_rng_affected_by_latm_km = obj.bs_rng_mid_km;
                end

                % Calc loss over the affected bs rng
                func_result = db_loss_factor * bs_rng_affected_by_latm_km;

                obj.model_cache('l_atm_oneway_db_mid') = func_result;
                val = func_result;
            end
        end

        function val = get.l_atm_oneway_db_far(obj)
            if isKey(obj.model_cache, 'l_atm_oneway_db_far')
                val = obj.model_cache('l_atm_oneway_db_far');
            else
                freq_ghz = obj.tx_freq_ghz;

                if freq_ghz == 37
                    db_loss_factor = obj.const_latm_37g_1way_dbkm;
                elseif freq_ghz == 90
                    db_loss_factor = obj.const_latm_90g_1way_dbkm;
                elseif freq_ghz == 150
                    db_loss_factor = obj.const_latm_150g_1way_dbkm;
                else
                    error('Function input "obj.tx_freq_ghz" must be one of "37GHz", "90GHz", or "150GHz".')
                end

                % Get bs dist affected by latm
                bs_rng_affected_by_latm_km = obj.const_latm_eff_max_altitude_km / sin(deg2rad(obj.ant_bs_grazing_ang_far_deg));

                % NB: The following shouldn't ever happen due to aircraft alt minimums, but check for this situation anyway
                if obj.bs_rng_far_km < bs_rng_affected_by_latm_km
                    bs_rng_affected_by_latm_km = obj.bs_rng_far_km;
                end

                % Calc loss over the affected bs rng
                func_result = db_loss_factor * bs_rng_affected_by_latm_km;

                obj.model_cache('l_atm_oneway_db_far') = func_result;
                val = func_result;
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
                tau = obj.tx_pulse_width_sec;
                func_result = (1 / tau);

                obj.model_cache('rx_minus3dB_bw_predet') = func_result;
                val = func_result;
            end
        end

        function val = get.ant_hpbw_elevation_deg(obj)
            if isKey(obj.model_cache, 'ant_hpbw_elevation_deg')
                val = obj.model_cache('ant_hpbw_elevation_deg');
            else
                % This calculation produces radians, co convert to degrees to meet caller expectations
                func_result = rad2deg(1.2 * (obj.freq2wavelen(obj.tx_freq_ghz * 1e+09)) / obj.ant_dim_elev_m);

                obj.model_cache('ant_hpbw_elevation_deg') = func_result;
                val = func_result;
            end
        end

        function val = get.ant_hpbw_azimuth_deg(obj)
            if isKey(obj.model_cache, 'ant_hpbw_azimuth_deg')
                val = obj.model_cache('ant_hpbw_azimuth_deg');
            else
                % This calculation produces radians, co convert to degrees to meet caller expectations
                func_result = rad2deg(1.2 * (obj.freq2wavelen(obj.tx_freq_ghz * 1e+09)) / obj.ant_dim_azim_m);

                obj.model_cache('ant_hpbw_azimuth_deg') = func_result;
                val = func_result;
            end
        end

        function val = get.tx_ant_gain(obj)
            if isKey(obj.model_cache, 'tx_ant_gain')
                val = obj.model_cache('tx_ant_gain');
            else
                func_result = (0.6 * 4 * pi) / ...
                    (deg2rad(obj.ant_hpbw_elevation_deg) * deg2rad(obj.ant_hpbw_azimuth_deg));

                obj.model_cache('tx_ant_gain') = func_result;
                val = func_result;
            end
        end

        function val = get.tx_ant_gain_db(obj)
            val = obj.ratio2db(obj.tx_ant_gain);
        end

        function val = get.pulse_rng_res_near_m(obj)
            if isKey(obj.model_cache, 'pulse_rng_res_near_m')
                val = obj.model_cache('pulse_rng_res_near_m');
            else
                func_result = obj.spd_of_light_m_per_sec * obj.tx_pulse_width_sec / (2 * cos(deg2rad(obj.ant_bs_grazing_ang_near_deg)));

                obj.model_cache('pulse_rng_res_near_m') = func_result;
                val = func_result;
            end
        end

        function val = get.pulse_rng_res_mid_m(obj)
            if isKey(obj.model_cache, 'pulse_rng_res_mid_m')
                val = obj.model_cache('pulse_rng_res_mid_m');
            else
                func_result = obj.spd_of_light_m_per_sec * obj.tx_pulse_width_sec / (2 * cos(deg2rad(obj.ant_bs_grazing_ang_mid_deg)));

                obj.model_cache('pulse_rng_res_mid_m') = func_result;
                val = func_result;
            end
        end

        function val = get.pulse_rng_res_far_m(obj)
            if isKey(obj.model_cache, 'pulse_rng_res_far_m')
                val = obj.model_cache('pulse_rng_res_far_m');
            else
                func_result = obj.spd_of_light_m_per_sec * obj.tx_pulse_width_sec / (2 * cos(deg2rad(obj.ant_bs_grazing_ang_far_deg)));

                obj.model_cache('pulse_rng_res_far_m') = func_result;
                val = func_result;
            end
        end

        function val = get.worst_case_pulse_rng_res_m(obj)
            val = min([obj.pulse_rng_res_near_m, ...
                           obj.pulse_rng_res_mid_m, ...
                           obj.pulse_rng_res_far_m]);
        end

        function val = get.pulse_azim_res_near_m(obj)
            if isKey(obj.model_cache, 'pulse_azim_res_near_m')
                val = obj.model_cache('pulse_azim_res_near_m');
            else
                func_result = (obj.bs_rng_near_km * 1000) * deg2rad(obj.ant_hpbw_azimuth_deg);

                obj.model_cache('pulse_azim_res_near_m') = func_result;
                val = func_result;
            end
        end

        function val = get.pulse_azim_res_mid_m(obj)
            if isKey(obj.model_cache, 'pulse_azim_res_mid_m')
                val = obj.model_cache('pulse_azim_res_mid_m');
            else
                func_result = (obj.bs_rng_mid_km * 1000) * deg2rad(obj.ant_hpbw_azimuth_deg);

                obj.model_cache('pulse_azim_res_mid_m') = func_result;
                val = func_result;
            end
        end

        function val = get.pulse_azim_res_far_m(obj)
            if isKey(obj.model_cache, 'pulse_azim_res_far_m')
                val = obj.model_cache('pulse_azim_res_far_m');
            else
                func_result = (obj.bs_rng_far_km * 1000) * deg2rad(obj.ant_hpbw_azimuth_deg);

                obj.model_cache('pulse_azim_res_far_m') = func_result;
                val = func_result;
            end
        end

        function val = get.worst_case_pulse_azim_res_m(obj)
            val = min([obj.pulse_azim_res_near_m, ...
                           obj.pulse_azim_res_mid_m, ...
                           obj.pulse_azim_res_far_m]);
        end

        function val = get.ifov_near_sq_m(obj)
            if isKey(obj.model_cache, 'ifov_near_sq_m')
                val = obj.model_cache('ifov_near_sq_m');
            else
                func_result = obj.pulse_rng_res_near_m * obj.pulse_azim_res_near_m;

                obj.model_cache('ifov_near_sq_m') = func_result;
                val = func_result;
            end
        end

        function val = get.ifov_mid_sq_m(obj)
            if isKey(obj.model_cache, 'ifov_mid_sq_m')
                val = obj.model_cache('ifov_mid_sq_m');
            else
                func_result = obj.pulse_rng_res_mid_m * obj.pulse_azim_res_mid_m;

                obj.model_cache('ifov_mid_sq_m') = func_result;
                val = func_result;
            end
        end

        function val = get.ifov_far_sq_m(obj)
            if isKey(obj.model_cache, 'ifov_far_sq_m')
                val = obj.model_cache('ifov_far_sq_m');
            else
                func_result = obj.pulse_rng_res_far_m * obj.pulse_azim_res_far_m;

                obj.model_cache('ifov_far_sq_m') = func_result;
                val = func_result;
            end
        end

        function val = get.time_on_target_sec(obj)
            if isKey(obj.model_cache, 'time_on_target_sec')
                val = obj.model_cache('time_on_target_sec');
            else
                func_result = (1 / (obj.ant_spin_rate_rpm / 60)) * ...
                    (obj.ant_hpbw_azimuth_deg / 360);

                obj.model_cache('time_on_target_sec') = func_result;
                val = func_result;
            end
        end

        function val = get.doppler_time_on_target_sec(obj)
            if isKey(obj.model_cache, 'doppler_time_on_target_sec')
                val = obj.model_cache('doppler_time_on_target_sec');
            else
                func_result = obj.time_on_target_sec * double(obj.scan_qty_on_tgt_intent);
                obj.model_cache('doppler_time_on_target_sec') = func_result;
                val = func_result;
            end
        end

        function val = get.pulses_on_target(obj)
            if isKey(obj.model_cache, 'pulses_on_target')
                val = obj.model_cache('pulses_on_target');
            else
                % NB: Don't round the POT value down yet (partial pulses normally don't count)
                %     because of a special case in HW04-P1.
                pot = obj.tx_prf_hz * obj.time_on_target_sec;

                % Perform tiebreaker which guarantees a "correct" result that matches
                % the value given in the answer sheet for HW01-P1.

                if mod(pot, 1) >= 0.99
                    func_result = ceil(pot);
                else
                    func_result = floor(pot);
                end

                obj.model_cache('pulses_on_target') = func_result;
                val = func_result;
            end
        end

        function val = get.rtt_near_sec(obj)
            if isKey(obj.model_cache, 'rtt_near_sec')
                val = obj.model_cache('rtt_near_sec');
            else
                func_result = ((obj.bs_rng_near_km * 1000) * 2) / obj.spd_of_light_m_per_sec;

                obj.model_cache('rtt_near_sec') = func_result;
                val = func_result;
            end
        end

        function val = get.rtt_mid_sec(obj)
            if isKey(obj.model_cache, 'rtt_mid_sec')
                val = obj.model_cache('rtt_mid_sec');
            else
                func_result = ((obj.bs_rng_mid_km * 1000) * 2) / obj.spd_of_light_m_per_sec;

                obj.model_cache('rtt_mid_sec') = func_result;
                val = func_result;
            end
        end

        function val = get.rtt_far_sec(obj)
            if isKey(obj.model_cache, 'rtt_far_sec')
                val = obj.model_cache('rtt_far_sec');
            else
                func_result = ((obj.bs_rng_far_km * 1000) * 2) / obj.spd_of_light_m_per_sec;
                obj.model_cache('rtt_far_sec') = func_result;
                val = func_result;
            end
        end

        function val = get.scan_fov_overlap_pct(obj)
            if isKey(obj.model_cache, 'scan_fov_overlap_pct')
                val = obj.model_cache('scan_fov_overlap_pct');
            else
                dist_gndtrk_far_km = obj.bs_rng_far_km * cos(deg2rad(obj.ant_bs_grazing_ang_far_deg));
                dist_gndtrk_near_km = obj.bs_rng_near_km * cos(deg2rad(obj.ant_bs_grazing_ang_near_deg));
                dist_scan_overlap = dist_gndtrk_far_km - (dist_gndtrk_near_km + (obj.const_ac_gnd_speed_kmh / (60 * 60)) * obj.t_spin_sec);

                func_result = double(dist_scan_overlap / obj.fov_range_km);

                obj.model_cache('scan_fov_overlap_pct') = func_result;
                val = func_result;
            end
        end

        function val = get.max_prf_supported_hz(obj)
            if isKey(obj.model_cache, 'max_prf_supported_hz')
                val = obj.model_cache('max_prf_supported_hz');
            else
                func_result = 1 / (obj.rtt_far_sec - obj.rtt_near_sec);

                obj.model_cache('max_prf_supported_hz') = func_result;
                val = func_result;
            end
        end

        function val = get.min_spin_rate_supported_rpm(obj)
            % warning('Min Reqd. Spin Rate is +0.487 dB from DrJ value. This calculation and dependent functions may yield inaccurate results!')
            if isKey(obj.model_cache, 'min_spin_rate_supported_rpm')
                val = obj.model_cache('min_spin_rate_supported_rpm');
            else
                overlap_dist_m = (1000 * obj.scan_fov_overlap_pct * obj.fov_range_km);
                tot_rel_speed_m_per_sec = (1000 * (obj.const_tgt_speed_max_kmh + obj.const_ac_gnd_speed_kmh)) / (60 * 60);

                tgt_time_in_overlap_box_sec = overlap_dist_m / tot_rel_speed_m_per_sec;

                time_per_spin_sec = tgt_time_in_overlap_box_sec / double(obj.scan_qty_on_tgt_intent);

                func_result = 60 / time_per_spin_sec;

                obj.model_cache('min_spin_rate_supported_rpm') = func_result;
                val = func_result;
            end
        end

        function val = get.requirements_check(obj)
            specs = readstruct(obj.const_requirements_json_file);
            results = configureDictionary('string', 'uint8');

            %% Swath Width
            if obj.swath_width_km >= getfield(specs, 'swath_width', 'required', 'value')
                results('swath_width') = 1;
            else
                results('swath_width') = 0;
            end

            %% Tx Pulse Width
            warning('Couldn''t find a spec to eval pulse width against!')

            %% Ant Dimension Azimuth
            if obj.ant_dim_azim_m <= getfield(specs, 'ant_dim_azim', 'required', 'value')
                results('ant_dim_azim') = 1;
            else
                results('ant_dim_azim') = 0;
            end

            %% Ant Dimension Elevation
            if obj.ant_dim_elev_m <= getfield(specs, 'ant_dim_elev', 'required', 'value')
                results('ant_dim_elev') = 1;
            else
                results('ant_dim_elev') = 0;
            end

            %% Ant Grazing Ang Far
            if obj.ant_bs_grazing_ang_far_deg >= specs.ant_bs_grazing_ang_far.required.value
                results('ant_bs_grazing_ang_far') = 1;
            else
                results('ant_bs_grazing_ang_far') = 0;
            end

            %% PRF Acceptable for Delta Range
            if obj.tx_prf_hz <= obj.max_prf_supported_hz
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
            if obj.ant_spin_rate_rpm <= getfield(specs, 'ant_spin_rate', 'required', 'value')
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
            if obj.ant_spin_rate_rpm >= obj.min_spin_rate_supported_rpm
                results('ant_spin_rate_ensures_nomissedtgt') = 1;
            else
                results('ant_spin_rate_ensures_nomissedtgt') = 0;
            end

            %% T_warn
            if obj.t_warn_sec >= getfield(specs, 't_warn', {1}, 'required', 'value')
                results('t_warn') = 1;
            else
                results('t_warn') = 0;
            end

            %% Tx Duty Cycle for Search & Doppler Modes
            if obj.tx_duty_cycle <= getfield(specs, 'tx_duty_cycle', {1}, 'required', 'value')
                results('tx_duty_cycle_search') = 1;
            else
                results('tx_duty_cycle_search') = 0;
            end

            if obj.tx_duty_cycle <= getfield(specs, 'tx_duty_cycle', {2}, 'required', 'value')
                results('tx_duty_cycle_doppler') = 1;
            else
                results('tx_duty_cycle_doppler') = 0;
            end

            %% Range Gate Resolution on Surface
            wc_range_gate_m = min([obj.pulse_rng_res_near_m, ...
                                       obj.pulse_rng_res_mid_m, ...
                                       obj.pulse_rng_res_far_m]);

            if wc_range_gate_m >= getfield(specs, 'fov_range', 'required', 'value')
                results('fov_range_gate') = 1;
            else
                results('fov_range_gate') = 0;
            end

            %% Azimuth Resolution on Surface (Delta Az)
            % NB: Customer requirement is in METERS, not KM
            if (obj.fov_azimuth_km * 1000) >= getfield(specs, 'fov_azimuth', 'required', 'value')
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
            if obj.tx_prf_hz <= getfield(specs, 'tx_prf', 'required', 'value')
                results('tx_prf') = 1;
            else
                results('tx_prf') = 0;
            end

            %% PRF Satisfies Nyquist Minimums
            if obj.tx_prf_hz >= obj.worst_case_nyquist_reqd_for_max_doppler_hz
                results('prf_meets_nyquist_wc') = 1;
            else
                results('prf_meets_nyquist_wc') = 0;
            end

            %% Doppler Precision Worst Case
            if obj.worst_case_doppler_precision_hz <= getfield(specs, 'doppler_precision', {1}, 'required', 'value')
                results('doppler_precision_wc') = 1;
            else
                results('doppler_precision_wc') = 0;
            end

            % NB: The following requirement checks DON'T appear on DrJ check sheets but are still needed

            %% Tx Power
            if obj.tx_power_w <= specs.tx_power.required.value
                results('tx_power') = 1;
            else
                results('tx_power') = 0;
            end

            %% Doppler Precision Supports Min. Delta Doppler Scenario
            doppler_case_deltas = zeros(9, 1);
            [doppler_case_deltas(1), ~] = obj.doppler_case1_center;
            [doppler_case_deltas(2), ~] = obj.doppler_case1_edge;
            [doppler_case_deltas(3), ~] = obj.doppler_case2_center;
            [doppler_case_deltas(4), ~] = obj.doppler_case2_edge;
            [doppler_case_deltas(5), ~] = obj.doppler_case3_center_plus;
            [doppler_case_deltas(6), ~] = obj.doppler_case3_center_minus;
            [doppler_case_deltas(7), ~] = obj.doppler_case3_edge_plus;
            [doppler_case_deltas(8), ~] = obj.doppler_case3_edge_minus;
            [doppler_case_deltas(9), ~] = obj.doppler_case4_center;

            if min(abs(doppler_case_deltas)) < (2 * obj.worst_case_doppler_precision_hz)
                results('doppler_prcsn_detects_min_delta') = 0;
            else
                results('doppler_prcsn_detects_min_delta') = 1;
            end

            val = results;
        end

        function val = get.goals_check(obj)
            specs = readstruct(obj.const_requirements_json_file);
            results = configureDictionary('string', 'single');

            %% Ant Dimension Elevation
            if obj.ant_dim_elev_m <= specs.ant_dim_elev.goal.value
                results('ant_dim_elev') = 1;
            elseif obj.ant_dim_elev_m <= specs.ant_dim_elev.required.value
                tmp_elev_linspace = linspace(double(specs.ant_dim_elev.required.value), double(specs.ant_dim_elev.goal.value));
                results('ant_dim_elev') = single(knnsearch(tmp_elev_linspace', obj.ant_dim_elev_m)) / 100;
            else
                results('ant_dim_elev') = 0;
            end

            %% Ant Dimension Azimuth
            if obj.ant_dim_azim_m <= specs.ant_dim_azim.goal.value
                results('ant_dim_azim') = 1;
            elseif obj.ant_dim_azim_m <= specs.ant_dim_azim.required.value
                tmp_azim_linspace = linspace(double(specs.ant_dim_azim.required.value), double(specs.ant_dim_azim.goal.value));
                results('ant_dim_azim') = single(knnsearch(tmp_azim_linspace', obj.ant_dim_azim_m)) / 100;
            else
                results('ant_dim_azim') = 0;
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
            if obj.ant_spin_rate_rpm <= specs.ant_spin_rate.goal.value
                results('ant_spin_rate') = 1;
            elseif obj.ant_spin_rate_rpm <= specs.ant_spin_rate.required.value
                mp_spinrt_linspace = linspace(double(specs.ant_spin_rate.goal.value), double(specs.ant_spin_rate.required.value));
                results('ant_spin_rate') = single(knnsearch(mp_spinrt_linspace', obj.ant_spin_rate_rpm)) / 100;
            else
                results('ant_spin_rate') = 0;
            end

            %% T_warn
            if obj.t_warn_sec >= specs.t_warn.goal.value
                results('t_warn') = 1;
            elseif obj.t_warn_sec >= specs.t_warn.required.value
                tmp_twarn_linspace = linspace(double(specs.t_warn.required.value), double(specs.t_warn.goal.value));
                results('t_warn') = single(knnsearch(tmp_twarn_linspace', obj.t_warn_sec)) / 100;
            else
                results('t_warn') = 0;
            end

            %% N out of M Probability of Detection
            wc_p_det_nofm = obj.worst_case_p_det_n_of_m;
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
            if obj.worst_case_doppler_precision_hz <= specs.doppler_precision.goal.value
                results('doppler_precision') = 1;
            elseif obj.worst_case_doppler_precision_hz <= specs.doppler_precision.required.value
                tmp_dopprec_linspace = linspace(double(specs.doppler_precision.goal.value), double(specs.doppler_precision.required.value));
                results('doppler_precision') = single(knnsearch(tmp_dopprec_linspace', obj.worst_case_doppler_precision_hz)) / 100;
            else
                results('doppler_precision') = 0;
            end

            %% Tx Power
            if obj.tx_power_w <= specs.tx_power.goal.value
                results('tx_power') = 1;
            elseif obj.tx_power_w <= specs.tx_power.required.value
                tmp_txpwr_linspace = linspace(double(specs.tx_power.required.value), double(specs.tx_power.goal.value));
                results('tx_power') = single(knnsearch(tmp_txpwr_linspace', obj.tx_power_w)) / 100;
            else
                results('tx_power') = 0;
            end

            %% Swath Width
            if obj.swath_width_km >= specs.swath_width.goal.value
                results('swath_width') = 1;
            elseif obj.swath_width_km >= specs.swath_width.required.value
                tmp_swathw_linspace = linspace(double(specs.swath_width.required.value), double(specs.swath_width.goal.value));
                results('swath_width') = single(knnsearch(tmp_swathw_linspace', obj.swath_width_km)) / 100;
            else
                results('swath_width') = 0;
            end

            val = results;
        end

        function val = get.max_expected_doppler_freq_near_hz(obj)
            if isKey(obj.model_cache, 'max_expected_doppler_freq_near_hz')
                val = obj.model_cache('max_expected_doppler_freq_near_hz');
            else
                tot_rel_speed_m_per_sec = (1000 * (obj.const_tgt_speed_max_kmh + obj.const_ac_gnd_speed_kmh)) / (60 * 60);
                v_radial_speed_m_per_sec = tot_rel_speed_m_per_sec * sin(deg2rad(90) - deg2rad(obj.ant_bs_grazing_ang_near_deg));

                func_result = (2 * v_radial_speed_m_per_sec) / (obj.freq2wavelen(obj.tx_freq_ghz * 1e+09));

                obj.model_cache('max_expected_doppler_freq_near_hz') = func_result;
                val = func_result;
            end
        end

        function val = get.max_expected_doppler_freq_mid_hz(obj)
            if isKey(obj.model_cache, 'max_expected_doppler_freq_mid_hz')
                val = obj.model_cache('max_expected_doppler_freq_mid_hz');
            else
                tot_rel_speed_m_per_sec = (1000 * (obj.const_tgt_speed_max_kmh + obj.const_ac_gnd_speed_kmh)) / (60 * 60);
                v_radial_speed_m_per_sec = tot_rel_speed_m_per_sec * sin(deg2rad(90) - deg2rad(obj.ant_bs_grazing_ang_mid_deg));

                func_result = (2 * v_radial_speed_m_per_sec) / (obj.freq2wavelen(obj.tx_freq_ghz * 1e+09));

                obj.model_cache('max_expected_doppler_freq_mid_hz') = func_result;
                val = func_result;
            end
        end

        function val = get.max_expected_doppler_freq_far_hz(obj)
            if isKey(obj.model_cache, 'max_expected_doppler_freq_far_hz')
                val = obj.model_cache('max_expected_doppler_freq_far_hz');
            else
                tot_rel_speed_m_per_sec = (1000 * (obj.const_tgt_speed_max_kmh + obj.const_ac_gnd_speed_kmh)) / (60 * 60);
                v_radial_speed_m_per_sec = tot_rel_speed_m_per_sec * sin(deg2rad(90) - deg2rad(obj.ant_bs_grazing_ang_far_deg));

                func_result = (2 * v_radial_speed_m_per_sec) / (obj.freq2wavelen(obj.tx_freq_ghz * 1e+09));

                obj.model_cache('max_expected_doppler_freq_far_hz') = func_result;
                val = func_result;
            end
        end

        function val = get.worst_case_max_expected_doppler_freq_hz(obj)
            function_result = max([obj.max_expected_doppler_freq_near_hz, ...
                                       obj.max_expected_doppler_freq_mid_hz, ...
                                       obj.max_expected_doppler_freq_far_hz]);

            val = function_result;
        end

        %% Doppler Proveout Helper Functions
        function val = tgt_delta_doppler_case_handler(obj, tgt_vel_dir_rel_rdr_bs_ang_deg, tgt_abs_speed_kmh)
            grz_angs_deg = [obj.ant_bs_grazing_ang_near_deg, obj.ant_bs_grazing_ang_mid_deg, obj.ant_bs_grazing_ang_far_deg];
            tgt_delta_doppler_hz = zeros(3, 1);

            for idx = 1:3
                tgt_gnd_speed_m_per_sec = (1000 * tgt_abs_speed_kmh) / (60 * 60);
                tgt_radial_vel = tgt_gnd_speed_m_per_sec * cosd(tgt_vel_dir_rel_rdr_bs_ang_deg) * cosd(grz_angs_deg(idx));
                tgt_delta_doppler_hz(idx) = obj.doppler_freq_hz(tgt_radial_vel, obj.freq2wavelen(obj.tx_freq_ghz * 1e+09));
            end

            func_result = max(tgt_delta_doppler_hz);
            val = func_result;
        end

        function val = tgt_total_doppler_case_handler(obj, ac_vel_dir_rel_tgt_ang_deg, tgt_vel_dir_rel_rdr_bs_ang_deg, tgt_abs_speed_kmh)
            grz_angs_deg = [obj.ant_bs_grazing_ang_near_deg, obj.ant_bs_grazing_ang_mid_deg, obj.ant_bs_grazing_ang_far_deg];

            tgt_delta_doppler_hz = zeros(3, 1);
            ac_doppler_hz = zeros(3, 1);
            tgt_total_doppler_hz = zeros(3, 1);

            for idx = 1:3
                ac_gnd_speed_m_per_sec = (1000 * obj.const_ac_gnd_speed_kmh) / (60 * 60);
                ac_radial_vel = ac_gnd_speed_m_per_sec * cosd(ac_vel_dir_rel_tgt_ang_deg) * sind(90 - grz_angs_deg(idx));
                ac_doppler_hz(idx) = obj.doppler_freq_hz(ac_radial_vel, obj.freq2wavelen(obj.tx_freq_ghz * 1e+09));

                tgt_gnd_speed_m_per_sec = (1000 * tgt_abs_speed_kmh) / (60 * 60);
                tgt_radial_vel = (tgt_gnd_speed_m_per_sec * cosd(tgt_vel_dir_rel_rdr_bs_ang_deg)) * cosd(grz_angs_deg(idx));
                tgt_delta_doppler_hz(idx) = obj.doppler_freq_hz(tgt_radial_vel, obj.freq2wavelen(obj.tx_freq_ghz * 1e+09));

                tgt_total_doppler_hz(idx) = ac_doppler_hz(idx) + tgt_delta_doppler_hz(idx);
            end

            func_result = max(tgt_total_doppler_hz);
            val = func_result;
        end

        function [delta, total] = doppler_case1_center(obj)
            delta = obj.tgt_delta_doppler_case_handler(0, obj.const_tgt_speed_max_kmh);
            total = obj.tgt_total_doppler_case_handler(0, 0, obj.const_tgt_speed_max_kmh);
        end

        function [delta, total] = doppler_case1_edge(obj)
            delta = obj.tgt_delta_doppler_case_handler(0, obj.const_tgt_speed_max_kmh);
            total = obj.tgt_total_doppler_case_handler(obj.ant_azim_fwd_look_half_angle_deg, 0, obj.const_tgt_speed_max_kmh);
        end

        function [delta, total] = doppler_case2_center(obj)
            delta = obj.tgt_delta_doppler_case_handler(180, obj.const_tgt_speed_max_kmh);
            total = obj.tgt_total_doppler_case_handler(0, 180, obj.const_tgt_speed_max_kmh);
        end

        function [delta, total] = doppler_case2_edge(obj)
            delta = obj.tgt_delta_doppler_case_handler(180, obj.const_tgt_speed_max_kmh);
            total = obj.tgt_total_doppler_case_handler(obj.ant_azim_fwd_look_half_angle_deg, 180, obj.const_tgt_speed_max_kmh);
        end

        function [delta, total] = doppler_case3_center_plus(obj)
            delta = obj.tgt_delta_doppler_case_handler(60, obj.const_tgt_speed_max_kmh);
            total = obj.tgt_total_doppler_case_handler(0, 60, obj.const_tgt_speed_max_kmh);
        end

        function [delta, total] = doppler_case3_center_minus(obj)
            delta = obj.tgt_delta_doppler_case_handler((180 - 60), obj.const_tgt_speed_max_kmh);
            total = obj.tgt_total_doppler_case_handler(0, (180 - 60), obj.const_tgt_speed_max_kmh);
        end

        function [delta, total] = doppler_case3_edge_plus(obj)
            delta = obj.tgt_delta_doppler_case_handler(60, obj.const_tgt_speed_max_kmh);
            total = obj.tgt_total_doppler_case_handler(obj.ant_azim_fwd_look_half_angle_deg, 60, obj.const_tgt_speed_max_kmh);
        end

        function [delta, total] = doppler_case3_edge_minus(obj)
            delta = obj.tgt_delta_doppler_case_handler((180 - 60), obj.const_tgt_speed_max_kmh);
            total = obj.tgt_total_doppler_case_handler(obj.ant_azim_fwd_look_half_angle_deg, (180 - 60), obj.const_tgt_speed_max_kmh);
        end

        function [delta, total] = doppler_case4_center(obj)
            delta = obj.tgt_delta_doppler_case_handler(0, obj.const_tgt_speed_min_kmh);
            total = obj.tgt_total_doppler_case_handler(0, 0, obj.const_tgt_speed_min_kmh);
        end
    end
end
