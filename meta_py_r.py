##############################################################
#
#  Byron C. Wallace
#  Tufts Medical Center
#  OpenMeta[analyst]
#
#  This is a proxy module that is responsible for communicating with R. 
#   **All calls to R (equivalently, all references to the rpy2 library) are to
#   be made via this module **
#  
###############################################################

import math
import os


try:
    import rpy2
    from rpy2 import robjects as ro
except:
    raise Exception, "rpy2 not properly installed!"

try:
    print "\nloading R libraries..."
    ro.r("library(metafor)")
    ro.r("library(openmetar)")
    print "openmetaR package succesfully loaded"
except:
    raise Exception, "metafor (R) package not installed.\nPlease install this package and then re-start OpenMeta."
    
try:
    # @TODO integrate into openmetar package
    # this is extremely kludgey and will likely break on other platforms
    cur_dir =  os.getcwd().replace("\\", "//")
    print cur_dir
    ro.r("setwd('%s')" % cur_dir)
    ro.r("source('data_transform.R')")
except:
    raise Exception, "whoops, data_transform.R script unavailable."
    
try:
    if not ro.r("file.exists('./.r_tmp')")[0]:
        print("creating tmp R directory...")
        ro.r("dir.create('./r_tmp')")
        print("success -- temporary results will be written to ./r_tmp")
except:
    raise Exception, "unable to create temporary directory for results! make sure you have sufficient permissions."
    
def impute_two_by_two(bin_data_dict):
    print "imputing 2x2 table via R..."
    print bin_data_dict
    
    # rpy2 doesn't know how to handle None types.
    # we can just remove them from the dictionary.
    for param, val in bin_data_dict.items():
        if val is None:
            bin_data_dict.pop(param)
    
    dataf = ro.r['data.frame'](**bin_data_dict)
    two_by_two = ro.r('impute.bin.data(bin.data=%s)' % dataf.r_repr())
    print two_by_two
    
def none_to_null(x):
    if x is None:
        return ro.r['as.null']()
    return x
    
def get_params(method_name):
    param_list = ro.r("%s.parameters()" % method_name)
    return (_rlist_to_pydict(param_list[0]), _rlist_to_pydict(param_list[1]))
    

def get_available_methods(for_data_type=None):
    '''
    Returns a list of methods available in OpenMeta for the particular data_type (if one is given).
    Excludes "*.parameters" methods
    '''
    method_list = ro.r("lsf.str('package:openmetar')")
    # by convention, the methods available for a data type (e.g., binary)
    # start with the name of the data type. furthermore, the parameters
    # for those methods are returned by a method with a name
    # ending in ".parameters"
    all_methods = [method for method in method_list if not method.endswith(".parameters")]
    if for_data_type is not None:
        all_methods = [method for method in all_methods if method.startswith(for_data_type)]
    return all_methods
    
def ma_dataset_to_simple_binary_robj(table_model, var_name="tmp_obj"):
    '''
    This converts a DatasetModel to a OpenMetaData (OMData) R object. We use type DatasetModel
    rather than a DataSet model directly to access the current variables. By 'simple'
    we mean that this method returns a single outcome single follow-up (defined as the
    the currently selected, as indicated by the model object) data object.
   
     @TODO 
        - we don't want to force the data object to be populated with 2x2 data as we currently do
            i.e., need to be able to pass just effect sizes
        - implement methods for more advanced conversions, i.e., for multiple outcome datasets
    '''
    raw_data = table_model.get_cur_raw_data()

    g1_events = _get_col(raw_data, 0)
    g1O1_str = ", ".join(_to_strs(g1_events))
    g1_totals = _get_col(raw_data, 1)
    g1O2 = [(total_i-event_i) for total_i, event_i in zip(g1_totals, g1_events)]
    g1O2_str = ", ".join(_to_strs(g1O2))
    
    g2_events = _get_col(raw_data, 2)
    g2O1_str = ", ".join(_to_strs(g2_events))
    g2_totals = _get_col(raw_data, 3)
    g2O2 = [(total_i-event_i) for total_i, event_i in zip(g2_totals, g2_events)]
    g2O2_str = ", ".join(_to_strs(g2O2))
    
    r_str = "%s <- new('BinaryData', g1O1=c(%s), g1O2=c(%s), g2O1=c(%s), g2O2=c(%s))"\
                    % (var_name, g1O1_str, g1O2_str, g2O1_str, g2O2_str)
    print "executing: %s" % r_str 
    ro.r(r_str)
    print "ok."
    return r_str
 
def run_binary_ma(params, bin_data_name="tmp_obj"):
    params_df = ro.r['data.frame'](**params)
    print "\n\n"
    print params
    result = ro.r("binary.rmh(%s, %s)" % (bin_data_name, params_df.r_repr()))
    return result
    
def _rlist_to_pydict(r_ls):
    d = {}
    names = r_ls.names
    for name, val in zip(names, r_ls):
        cur_x = list(val)
        if len(cur_x) == 1:
            d[name] = cur_x[0]
        else:
            d[name] = cur_x
    return d
    
def _get_c_str_for_col(m, i):
    return ", ".join(self._get_col(m, i))
    
def _to_strs(v):
    return [str(x) for x in v]
    
def _get_col(m, i):
    col_vals = []
    for x in m:
        col_vals.append(x[i])
    return col_vals
    
def effect_for_study(e1, n1, e2, n2, metric="OR", conf_level=.975):
    '''
    Computes a point estimate, lower & upper bound for 
    the parametric 2x2 table data.
    
    @TODO add support for non-normal (e.g., T) distributions
    
    @params
    ===
    e1 -- events in group 1
    n1 -- size of group 1
    e2 -- events in group 2
    n2 -- size of group 2
    '''
    print metric
    r_str = "escalc(measure='%s', ai=c(%s), n1i=c(%s), ci=c(%s), n2i=c(%s))" %\
                    (metric, e1, n1, e2, n2)
    
    effect = ro.r(r_str)
    lg_point_est = effect[0][0]
    v = math.sqrt(effect[1][0])
    
    # scalar for computing confidence interval
    r_str = "qnorm(%s)" % conf_level
    scalar = ro.r(r_str)[0]    
    
    lower, upper = (math.exp(lg_point_est-scalar*v), math.exp(lg_point_est+scalar*v))
    point_est, lower, upper = [math.exp(lg_point_est), lower, upper]
    print "%s, %s, %s" % (lower, point_est, upper)
    
    return (point_est, lower, upper)