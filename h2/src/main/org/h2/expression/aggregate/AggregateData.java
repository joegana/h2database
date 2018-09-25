/*
 * Copyright 2004-2018 H2 Group. Multiple-Licensed under the MPL 2.0,
 * and the EPL 1.0 (http://h2database.com/html/license.html).
 * Initial Developer: H2 Group
 */
package org.h2.expression.aggregate;

import org.h2.engine.Database;
import org.h2.expression.aggregate.Aggregate.AggregateType;
import org.h2.message.DbException;
import org.h2.value.Value;

/**
 * Abstract class for the computation of an aggregate.
 */
abstract class AggregateData {

    /**
     * Create an AggregateData object of the correct sub-type.
     *
     * @param aggregateType the type of the aggregate operation
     * @param distinct if the calculation should be distinct
     * @return the aggregate data object of the specified type
     */
    static AggregateData create(AggregateType aggregateType, boolean distinct) {
        switch (aggregateType) {
        case COUNT_ALL:
            return new AggregateDataCountAll();
        case COUNT:
            if (!distinct) {
                return new AggregateDataCount();
            }
            break;
        case GROUP_CONCAT:
        case ARRAY_AGG:
        case MEDIAN:
            break;
        case MIN:
        case MAX:
        case BIT_OR:
        case BIT_AND:
        case BOOL_OR:
        case BOOL_AND:
            return new AggregateDataDefault(aggregateType);
        case SUM:
        case AVG:
        case STDDEV_POP:
        case STDDEV_SAMP:
        case VAR_POP:
        case VAR_SAMP:
            if (!distinct) {
                return new AggregateDataDefault(aggregateType);
            }
            break;
        case SELECTIVITY:
            return new AggregateDataSelectivity(distinct);
        case HISTOGRAM:
            return new AggregateDataHistogram(distinct);
        case MODE:
            return new AggregateDataMode();
        case ENVELOPE:
            return new AggregateDataEnvelope();
        default:
            throw DbException.throwInternalError("type=" + aggregateType);
        }
        return new AggregateDataCollecting(distinct);
    }

    /**
     * Add a value to this aggregate.
     *
     * @param database the database
     * @param dataType the datatype of the computed result
     * @param v the value
     */
    abstract void add(Database database, int dataType, Value v);

    /**
     * Get the aggregate result.
     *
     * @param database the database
     * @param dataType the datatype of the computed result
     * @return the value
     */
    abstract Value getValue(Database database, int dataType);
}
