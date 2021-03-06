!--------------------------------------------------------------------------------------------------!
! Copyright (C) by the DBCSR developers group - All rights reserved                                !
! This file is part of the DBCSR library.                                                          !
!                                                                                                  !
! For information on the license, see the LICENSE file.                                            !
! For further information please visit https://dbcsr.cp2k.org                                      !
! SPDX-License-Identifier: GPL-2.0+                                                                !
!--------------------------------------------------------------------------------------------------!

! **************************************************************************************************
!> \brief   DBCSR data types
!> \author  Urban Borstnik
!> \date    2009-05-12
!> \version 0.95
!>
!> <b>Modification history:</b>
!> - Created 2009-05-12
! **************************************************************************************************
MODULE dbcsr_types
   USE dbcsr_array_types, ONLY: array_i1d_obj
   USE dbcsr_btree, ONLY: btree_i8_cp2d, &
                          btree_i8_dp2d, &
                          btree_i8_sp2d, &
                          btree_i8_zp2d
   USE dbcsr_data_types, ONLY: &
      dbcsr_data_area_type, dbcsr_data_obj, dbcsr_datatype_sizeof, dbcsr_memtype_default, &
      dbcsr_memtype_type, dbcsr_scalar_type, dbcsr_type_complex_4, dbcsr_type_complex_4_2d, &
      dbcsr_type_complex_8, dbcsr_type_complex_8_2d, dbcsr_type_complex_default, &
      dbcsr_type_int_4, dbcsr_type_real_4, dbcsr_type_real_4_2d, dbcsr_type_real_8, &
      dbcsr_type_real_8_2d, dbcsr_type_real_default
   USE dbcsr_kinds, ONLY: default_string_length, &
                          int_8

!$ USE OMP_LIB, ONLY: omp_get_max_threads, omp_get_thread_num, omp_get_num_threads

   IMPLICIT NONE
   PRIVATE

   CHARACTER(len=*), PARAMETER, PRIVATE :: moduleN = 'dbcsr_types'

   PUBLIC :: dbcsr_type, &
             dbcsr_scalar_type, &
             dbcsr_data_obj, &
             dbcsr_data_area_type, &
             dbcsr_work_type, &
             dbcsr_1d_array_type, &
             dbcsr_2d_array_type, &
             dbcsr_mp_obj, &
             dbcsr_distribution_obj, &
             dbcsr_imagedistribution_type, &
             dbcsr_imagedistribution_obj, &
             dbcsr_iterator, &
             dbcsr_mutable_obj, &
             dbcsr_type_p
   PUBLIC :: dbcsr_meta_size
   PUBLIC :: dbcsr_slot_size, &
             dbcsr_slot_row_p, &
             dbcsr_slot_col_i, &
             dbcsr_slot_blk_p, &
             dbcsr_slot_thr_c, &
             dbcsr_slot_coo_l, &
             dbcsr_slot_nblks, &
             dbcsr_slot_nze, &
             dbcsr_slot_dense, &
             dbcsr_slot_nblkrows_total, &
             dbcsr_slot_nblkcols_total, &
             dbcsr_slot_nfullrows_total, &
             dbcsr_slot_nfullcols_total, &
             dbcsr_slot_nblkrows_local, &
             dbcsr_slot_nblkcols_local, &
             dbcsr_slot_nfullrows_local, &
             dbcsr_slot_nfullcols_local, &
             dbcsr_slot_type, &
             dbcsr_slot_home_prow, &
             dbcsr_slot_home_pcol, &
             dbcsr_slot_home_rowi, &
             dbcsr_slot_home_coli, &
             dbcsr_slot_home_vprow, &
             dbcsr_slot_home_vpcol, &
             dbcsr_num_slots

   PUBLIC :: dbcsr_mpi_size_limits

   PUBLIC :: dbcsr_type_real_4, dbcsr_type_real_8, &
             dbcsr_type_complex_4, dbcsr_type_complex_8, &
             dbcsr_type_real_default, dbcsr_type_complex_default, &
             dbcsr_type_real_4_2d, dbcsr_type_real_8_2d, &
             dbcsr_type_complex_4_2d, dbcsr_type_complex_8_2d, &
             dbcsr_type_int_4
   PUBLIC :: dbcsr_datatype_sizeof
   PUBLIC :: dbcsr_memtype_type, &
             dbcsr_memtype_default

   PUBLIC :: dbcsr_type_invalid, dbcsr_type_no_symmetry, dbcsr_type_symmetric, &
             dbcsr_type_antisymmetric, dbcsr_type_hermitian, dbcsr_type_antihermitian
   PUBLIC :: dbcsr_no_transpose, dbcsr_transpose, dbcsr_conjugate_transpose
   PUBLIC :: dbcsr_repl_none, dbcsr_repl_row, dbcsr_repl_col, dbcsr_repl_full

   PUBLIC :: dbcsr_filter_frobenius
   PUBLIC :: dbcsr_norm_frobenius, dbcsr_norm_maxabsnorm, &
             dbcsr_norm_gershgorin, dbcsr_norm_column

   PUBLIC :: dbcsr_func_inverse, dbcsr_func_tanh, dbcsr_func_dtanh, &
             dbcsr_func_ddtanh, dbcsr_func_artanh, dbcsr_func_inverse_special, &
             dbcsr_func_spread_from_zero, &
             dbcsr_func_sin, &
             dbcsr_func_dsin, &
             dbcsr_func_ddsin, &
             dbcsr_func_asin, &
             dbcsr_func_truncate, &
             dbcsr_func_cos

   PUBLIC :: dbcsr_2d_array_obj

   PUBLIC :: dbcsr_mpi_statistics_type

! **************************************************************************************************
!> \brief A processor (process) grid distribution
!> \var myproc                my processor (process) number
!> \var numproc               number of processors (processes)
!> \var myprow, mypcol        my process grid row and column
!> \var mp_group              message-passing group ID
!> \var pgrid                 processor grid
!> \var refcount              reference counter
!> \var subgroups_defined     whether the subgroups are defined
!> \var prow_group            per-process-row communicator
!> \var pcol_group            pre-process-column communicator
! **************************************************************************************************
   TYPE dbcsr_mp_type
      INTEGER                            :: mynode = -1
      INTEGER                            :: numnodes = -1
      INTEGER                            :: myprow = -1
      INTEGER                            :: mypcol = -1
      INTEGER                            :: mp_group = -1
      INTEGER, DIMENSION(:, :), POINTER  :: pgrid => Null()
      INTEGER                            :: refcount = 0
      LOGICAL                            :: subgroups_defined = .FALSE.
      INTEGER                            :: prow_group = -1
      INTEGER                            :: pcol_group = -1
      INTEGER                            :: source = -1
   END TYPE dbcsr_mp_type

! **************************************************************************************************
!> \brief A processor (process) grid distribution
!> \var myproc                my processor (process) number
!> \var numproc               number of processors (processes)
!> \var myprow, mypcol        my process grid row and column
!> \var pgrid                 processor grid
!> \var refcount              reference counter
! **************************************************************************************************
   TYPE dbcsr_mp_obj
      TYPE(dbcsr_mp_type), POINTER :: mp => Null()
   END TYPE dbcsr_mp_obj

! **************************************************************************************************
!> \brief Matrix distribution on the processor grid
!> \var row_dist, col_dist    standard row and column distributions of matrix
!>                            elements' rows and columns into processor grid
!>                            rows and columns
!> \var local_rows            list of rows local to the processor grid row
!> \var local_cols            list of columns local to the processor grid
!>                            column
!> \var other_l_rows          local rows for each process row
!> \var other_l_cols          local columns for each process column
!> \var has_other_l_rows      other_rows is defined
!> \var has_other_l_cols      other_cols is defined
!> \var global_row_map        mapping from rows to sequence in local rows
!>                            (global to local mapping)
!> \var global_col_map        mapping from rows to sequence in local columns
!>                            (global to local mapping)
!> \var has_global_row_map    whether other_row_map is defined
!> \var has_global_col_map    whether other_col_map is defined
!> \var row_map               distribution map for rows
!> \var col_map               distribution map for columns
!> \var thread_dist           thread distribution (of the rows)
!> \var numthreads            number of threads in the environment
!> \var mp_env                multiprocessor environment on which the
!>                            distribution is based
!> \var refcount              reference counter
! **************************************************************************************************
   TYPE dbcsr_distribution_type
      TYPE(array_i1d_obj)                        :: row_dist_block, col_dist_block
      TYPE(array_i1d_obj)                        :: local_rows, local_cols
      TYPE(array_i1d_obj)                        :: row_dist_cluster, col_dist_cluster
      INTEGER                                    :: max_row_dist, max_col_dist
      TYPE(array_i1d_obj), DIMENSION(:), POINTER :: other_l_rows => Null()
      TYPE(array_i1d_obj), DIMENSION(:), POINTER :: other_l_cols => Null()
      LOGICAL                                    :: has_other_l_rows = .FALSE.
      LOGICAL                                    :: has_other_l_cols = .FALSE.
      TYPE(array_i1d_obj)                        :: global_row_map
      TYPE(array_i1d_obj)                        :: global_col_map
      LOGICAL                                    :: has_global_row_map = .FALSE.
      LOGICAL                                    :: has_global_col_map = .FALSE.
      TYPE(array_i1d_obj)                        :: row_map
      TYPE(array_i1d_obj)                        :: col_map
      LOGICAL                                    :: has_thread_dist = .FALSE.
      TYPE(array_i1d_obj)                        :: thread_dist
      INTEGER                                    :: num_threads = -1
      TYPE(dbcsr_mp_obj)                         :: mp_env
      INTEGER                                    :: refcount = 0
   END TYPE dbcsr_distribution_type

   TYPE dbcsr_distribution_obj
      TYPE(dbcsr_distribution_type), POINTER  :: d => Null()
   END TYPE dbcsr_distribution_obj

! **************************************************************************************************
!> \brief Image distributions are used to map incompatible processor row and
!>        column distributions.
!>
!> Used to ease storage or transfer between two different-sizes
!> sets. For example, if there are 4 real processor rows that are
!> mapped to 8 "virtual" processor rows, then there are two images for
!> every real processor row.
!> \var main                            the main distribution
!> \var row_image, col_image            distribution of matrix elements' rows
!>                                      and columns into image  rows and
!>                                      columns
!> \var row_decimation, col_decimation  Number of imaged rows/columns mapped
!>                                      to a real row/column
!> \var row_multiplicity, col_multiplicity   Number of real rows/columns mapped
!>                                      to a virtual row/column
!> \var refcount                        count of references
! **************************************************************************************************
   TYPE dbcsr_imagedistribution_type
      TYPE(dbcsr_distribution_obj)               :: main
      TYPE(array_i1d_obj)                        :: row_image
      TYPE(array_i1d_obj)                        :: col_image
      INTEGER                                    :: row_decimation = -1
      INTEGER                                    :: col_decimation = -1
      INTEGER                                    :: row_multiplicity = -1
      INTEGER                                    :: col_multiplicity = -1
      TYPE(array_i1d_obj)                        :: vrow_dist
      TYPE(array_i1d_obj)                        :: vcol_dist
      TYPE(array_i1d_obj), DIMENSION(:), POINTER :: other_vl_rows => Null()
      TYPE(array_i1d_obj), DIMENSION(:), POINTER :: other_vl_cols => Null()
      TYPE(array_i1d_obj)                        :: global_vrow_map
      TYPE(array_i1d_obj)                        :: global_vcol_map
      LOGICAL                                    :: has_other_vl_rows = .FALSE.
      LOGICAL                                    :: has_other_vl_cols = .FALSE.
      LOGICAL                                    :: has_global_vrow_map = .FALSE.
      LOGICAL                                    :: has_global_vcol_map = .FALSE.
      INTEGER                                    :: id = -1
      INTEGER                                    :: refcount = 0
   END TYPE dbcsr_imagedistribution_type

   TYPE dbcsr_imagedistribution_obj
      TYPE(dbcsr_imagedistribution_type), POINTER :: i => Null()
   END TYPE dbcsr_imagedistribution_obj

   ! Different method for dbcsr_filter
   INTEGER, PARAMETER            :: dbcsr_filter_frobenius = 1

   ! Different norm for dbcsr_norm
   INTEGER, PARAMETER            :: dbcsr_norm_frobenius = 1
   INTEGER, PARAMETER            :: dbcsr_norm_maxabsnorm = 2
   INTEGER, PARAMETER            :: dbcsr_norm_gershgorin = 3
   INTEGER, PARAMETER            :: dbcsr_norm_column = 4

! **************************************************************************************************
!> \brief Buffer for blocks
!> \var refcount        Reference counter
!> \var dirty           Whether any buffers are dirty
!> \var buffers         Buffers
!> \var rcb             Row and column and offset and dimensions of data in the
!>                      buffer
!> \var main            Main memory
!> \var backing         Backing memory (in lieu of main memory)
!> \var data_type       Data type used for the buffers
! **************************************************************************************************
   TYPE dbcsr_block_buffer_type
      INTEGER                                     :: refcount = 0
      LOGICAL, DIMENSION(:), POINTER              :: dirty => Null()
      TYPE(dbcsr_data_obj), DIMENSION(:), POINTER :: buffers => Null()
      INTEGER, DIMENSION(:, :), POINTER           :: rcb => Null()
      TYPE(dbcsr_data_obj)                        :: main
      TYPE(dbcsr_data_obj), DIMENSION(:), POINTER :: backing => Null()
      INTEGER                                     :: data_type = -1
   END TYPE dbcsr_block_buffer_type

! **************************************************************************************************
!> \brief Object for the buffer of blocks
!> \var t               Block buffer
! **************************************************************************************************
   TYPE dbcsr_block_buffer_obj
      TYPE(dbcsr_block_buffer_type), POINTER :: b => Null()
   END TYPE dbcsr_block_buffer_obj

! **************************************************************************************************
!> \brief An iterator over a DBCSR matrix.
!> \note This is briefly changed to allow being included in the dbcsr_type type
!>       What is written here is what the structure should be and not what it
!>       is.
!> \var matrix           the matrix
!> \var buffer_2d        Buffers for repointing 2d pointers (1 per thread)
!> \var row              Current row (per thread)
!> \var pos              Current position (per thread)
!> \var row_size         Size of current row
!> \var rbs, cbs         Pointer to row and column size array
!> \var roff, coff       Pointer to row and column offset array
!> \var local_indexing   The matrix has local indexing
!> \var contiguous_pointers   Whether pointers to data should be contiguous
!>                            in memory.
!> \var shared           Iterators share matrix
!> \var dynamic          Ignores the thread distribution (FCFS by block)
!> \var dynamic_byrows   Ignores the thread distribution (FCFS by row)
!> \var common_pos       Position when in mixed mode (row or block
!>                       depending in dynamic_byrows
!> \var local_rows       Mapping of local rows to global rows (if local
!>                       indexing is enabled)
!> \var global_rows      Mapping of global rows to local rows (if local
!>                       indexing is enabled)
! **************************************************************************************************
   TYPE dbcsr_iterator
      TYPE(dbcsr_type), POINTER                       :: matrix => Null()
      TYPE(dbcsr_block_buffer_obj)                   :: buffer_2d
      INTEGER                                        :: pos = -1
      INTEGER                                        :: row = -1
      INTEGER                                        :: row_size = -1
      INTEGER                                        :: row_offset = -1
      INTEGER, DIMENSION(:), POINTER                 :: rbs => Null()
      INTEGER, DIMENSION(:), POINTER                 :: cbs => Null()
      INTEGER, DIMENSION(:), POINTER                 :: roff => Null()
      INTEGER, DIMENSION(:), POINTER                 :: coff => Null()
      LOGICAL                                        :: local_indexing = .FALSE.
      LOGICAL                                        :: contiguous_pointers = .FALSE.
      LOGICAL                                        :: transpose = .FALSE.
      LOGICAL                                        :: read_only = .FALSE.
      LOGICAL                                        :: shared = .FALSE.
      LOGICAL                                        :: dynamic = .FALSE.
      LOGICAL                                        :: dynamic_byrows = .FALSE.
      INTEGER, POINTER                               :: common_pos => Null()
      ! Copies from the matrix.
      INTEGER                                        :: nblks = -1
      INTEGER                                        :: nblkrows_total = -1
      INTEGER, DIMENSION(:), POINTER                 :: row_p => Null()
      INTEGER, DIMENSION(:), POINTER                 :: col_i => Null()
      INTEGER, DIMENSION(:), POINTER                 :: blk_p => Null()
      INTEGER, DIMENSION(:), POINTER                 :: tdist => Null()
      INTEGER, DIMENSION(:), POINTER                 :: local_rows => Null()
      INTEGER, DIMENSION(:), POINTER                 :: global_rows => Null()
      TYPE(dbcsr_data_obj)                           :: data_area
   END TYPE dbcsr_iterator

! **************************************************************************************************
!> \brief Data area with random access reads, insertions, and deletions.
!> \var tree_s, tree_d, tree_c, tree_z  Data types for the various types
!> \var refcount                        Reference counter
!> \var data_type                       The data type that is stored
! **************************************************************************************************
   TYPE dbcsr_mutable_type
      TYPE(btree_i8_sp2d)          :: btree_s
      TYPE(btree_i8_dp2d)          :: btree_d
      TYPE(btree_i8_cp2d)          :: btree_c
      TYPE(btree_i8_zp2d)          :: btree_z
      INTEGER                   :: refcount = 0
      INTEGER                   :: data_type = -1
   END TYPE dbcsr_mutable_type

! **************************************************************************************************
!> \brief Object for the mutable data type
! **************************************************************************************************
   TYPE dbcsr_mutable_obj
      TYPE(dbcsr_mutable_type), POINTER :: m => Null()
   END TYPE dbcsr_mutable_obj

! **************************************************************************************************
!> \brief Used for assembling a real matrix.
!> \var m           the final bcsr matrix
!> \var data_area   holds actual values.
!> \var row_i       the row index of all of the blocks.
!> \var col_i       the column index of all of the blocks.
!> \var blk_p       the pointer into the data array of this block.
!> \var lastblk     index of the last block entered into the row_i, col_i, and
!>                  blk_p data structures
!> \var datasize    the actual size of data present in the data element
!> \var tree        tree used to index data blocks (alternative to the row_i,
!>                  col_i, and blk_p indices when index is scattered).
! **************************************************************************************************
   TYPE dbcsr_work_type
      TYPE(dbcsr_data_obj)                    :: data_area
      INTEGER, DIMENSION(:), POINTER          :: row_i => Null()
      INTEGER, DIMENSION(:), POINTER          :: col_i => Null()
      INTEGER, DIMENSION(:), POINTER          :: blk_p => Null()
      INTEGER                                 :: lastblk = -1
      INTEGER                                 :: datasize = -1
      INTEGER                                 :: datasize_after_filtering = -1
      !TYPE(btree_i8_dp2d)                       :: tree
      TYPE(dbcsr_mutable_obj)                 :: mutable
   END TYPE dbcsr_work_type

! **************************************************************************************************
!> \brief The BCSR sparse matrix type.
!> \par arrays data and index hold the bulk of the data.
!> \var serial_number   a unique number of each created matrix
!> \var initialized whether the matrix is initialized (i.e., it is not random
!>                  garbage from memory)
!> \var valid       whether the matrix is valid (consistent)
!> \var name        name of the matrix
!> \var index(:)    agglomeration of the indices and offsets
!>                            of pointers into this array.
!> \par the pointers row_p, col_i, blk_p point into the index array.
!> \var row_p       points into the col_i and blk_p arrays, each element
!>                  (1:nblkrows_total+1) points to the previous row's last
!>                  element. So each rows has elements
!>                  row_p(row)+1:row_p(row+1).
!> \var coo_l       coordinate list (used for direct indexing)
!> \var col_i       the global blocked column number of this block.
!> \var blk_p       the pointer into the data array of this block.
!> \var thr_c       elements/thread for list index
!> \var row_blk_size          sizes (rows in a block) of blocked rows
!> \var col_blk_size          sizes (columns in a block) of blocked columns
!> \var row_blk_offset          row offset (size = nrow+1)
!> \var col_blk_offset          col offset (size = ncol+1)
!> \var max_rbs, max_cbs      maximal row and column sizes
!> \var dist        distribution used by this matrix
!> \var nblks       number of blocks locally present
!> \var nze         number of non-zero elements locally present
!> \var nblkrows_total, nblk_cols_total size of entire matrix in blocked rows
!>                  and blocked columns
!> \var nblkrows_local, nblk_cols_local size of local part of matrix in blocked
!>                  rows and blocked columns
!> \var nfullrows_total, nfull_cols_total size of entire matrix in full rows
!>                  and full columns
!> \var nfullrows_local, nfull_cols_local size of local part of matrix in full
!>                  rows and full columns
!> \var symmetry              matrix has symmetry
!> \var negate_real           symmetry is realized by negating the real part
!> \var negate_imaginary      symmetry is realized by negating complex part
!>                            (i.e., antisymmetric)
!> \var data_type             'r'/'R' for single/double precision real or
!>                            'c'/'C' for single/double precision complex data
!> \var replication_type      multi-process replication used in the matrix
!> \var transpose             matrix is logically transposed
!> \var bscs                  BCS Column instead of BCS Row
!> \var local_indexing        Local indexing of rows instead of global indexing.
!> \var local_rows            Map of local to global rows when local indexing
!>                            is enabled
!> \var local_rows            Map of global to local rows when local indexing
!>                            is enabled
!> \var index_memory_type     memory type for the index
!> \var data_memory_type      memory type for data
!> \var buffers               Block buffers
!> \var refcount              reference count
!> \var work_mutable          uses the mutable data for working and not the
!>                            append-only data
! **************************************************************************************************
   TYPE dbcsr_type
      INTEGER                                      :: serial_number = -1
      LOGICAL                                      :: valid = .FALSE.
      CHARACTER(LEN=default_string_length)         :: name = ""
      TYPE(dbcsr_data_obj)                         :: data_area = dbcsr_data_obj()
      INTEGER, DIMENSION(:), POINTER               :: index => Null()
      INTEGER, DIMENSION(:), POINTER               :: row_p => Null()
      INTEGER, DIMENSION(:), POINTER               :: col_i => Null()
      INTEGER, DIMENSION(:), POINTER               :: blk_p => Null()
      INTEGER, DIMENSION(:), POINTER               :: thr_c => Null()
      INTEGER, DIMENSION(:), POINTER               :: coo_l => Null()
      TYPE(array_i1d_obj)                          :: row_blk_size = array_i1d_obj()
      TYPE(array_i1d_obj)                          :: col_blk_size = array_i1d_obj()
      TYPE(array_i1d_obj)                          :: row_blk_offset = array_i1d_obj()
      TYPE(array_i1d_obj)                          :: col_blk_offset = array_i1d_obj()
      TYPE(array_i1d_obj)                          :: local_rows = array_i1d_obj()
      TYPE(array_i1d_obj)                          :: global_rows = array_i1d_obj()
      TYPE(array_i1d_obj)                          :: local_cols = array_i1d_obj()
      TYPE(array_i1d_obj)                          :: global_cols = array_i1d_obj()
      LOGICAL                                      :: has_local_rows = .FALSE.
      LOGICAL                                      :: has_global_rows = .FALSE.
      LOGICAL                                      :: has_local_cols = .FALSE.
      LOGICAL                                      :: has_global_cols = .FALSE.
      INTEGER                                      :: max_rbs = -1
      INTEGER                                      :: max_cbs = -1
      INTEGER                                      :: sparsity_id = -1
      INTEGER                                      :: id_nr = -1 ! use in sm_pool
      INTEGER                                      :: nblks = -1
      INTEGER                                      :: nze = -1
      INTEGER                                      :: nblkrows_total = -1
      INTEGER                                      :: nblkcols_total = -1
      INTEGER                                      :: nfullrows_total = -1
      INTEGER                                      :: nfullcols_total = -1
      INTEGER                                      :: nblkrows_local = -1
      INTEGER                                      :: nblkcols_local = -1
      INTEGER                                      :: nfullrows_local = -1
      INTEGER                                      :: nfullcols_local = -1
      INTEGER                                      :: data_type = -1
      CHARACTER                                    :: replication_type = ""
      LOGICAL                                      :: symmetry = .FALSE.
      LOGICAL                                      :: negate_real = .FALSE.
      LOGICAL                                      :: negate_imaginary = .FALSE.
      LOGICAL                                      :: bcsc = .FALSE.
      LOGICAL                                      :: local_indexing = .FALSE.
      LOGICAL                                      :: list_indexing = .FALSE.
      TYPE(dbcsr_memtype_type)                     :: data_memory_type = dbcsr_memtype_type()
      TYPE(dbcsr_memtype_type)                     :: index_memory_type = dbcsr_memtype_type()
      TYPE(dbcsr_block_buffer_obj)                 :: buffers = dbcsr_block_buffer_obj()
      TYPE(dbcsr_work_type), DIMENSION(:), POINTER :: wms => Null()
      TYPE(dbcsr_distribution_obj)                 :: dist = dbcsr_distribution_obj()
      INTEGER                                      :: refcount = 0
      LOGICAL                                      :: work_mutable = .FALSE.
   END TYPE dbcsr_type

   CHARACTER, PARAMETER        :: dbcsr_type_invalid = '0'
   CHARACTER, PARAMETER        :: dbcsr_type_no_symmetry = 'N'
   CHARACTER, PARAMETER        :: dbcsr_type_symmetric = 'S'
   CHARACTER, PARAMETER        :: dbcsr_type_antisymmetric = 'A'
   CHARACTER, PARAMETER        :: dbcsr_type_hermitian = 'H'
   CHARACTER, PARAMETER        :: dbcsr_type_antihermitian = 'K'

   !
   ! multiply transpositions
   CHARACTER, PARAMETER        :: dbcsr_no_transpose = 'N'
   CHARACTER, PARAMETER        :: dbcsr_transpose = 'T'
   CHARACTER, PARAMETER        :: dbcsr_conjugate_transpose = 'C'

   CHARACTER, PARAMETER        :: dbcsr_repl_none = 'N'
   CHARACTER, PARAMETER        :: dbcsr_repl_row = 'R'
   CHARACTER, PARAMETER        :: dbcsr_repl_col = 'C'
   CHARACTER, PARAMETER        :: dbcsr_repl_full = 'A'

   !
   ! Function types
   INTEGER, PARAMETER          :: dbcsr_func_inverse = 0
   INTEGER, PARAMETER          :: dbcsr_func_tanh = 1
   INTEGER, PARAMETER          :: dbcsr_func_dtanh = 2
   INTEGER, PARAMETER          :: dbcsr_func_ddtanh = 3
   INTEGER, PARAMETER          :: dbcsr_func_artanh = 4
   INTEGER, PARAMETER          :: dbcsr_func_inverse_special = 5
   INTEGER, PARAMETER          :: dbcsr_func_spread_from_zero = 6
   INTEGER, PARAMETER          :: dbcsr_func_sin = 7
   INTEGER, PARAMETER          :: dbcsr_func_dsin = 8
   INTEGER, PARAMETER          :: dbcsr_func_ddsin = 9
   INTEGER, PARAMETER          :: dbcsr_func_asin = 10
   INTEGER, PARAMETER          :: dbcsr_func_cos = 11
   INTEGER, PARAMETER          :: dbcsr_func_truncate = 12

! **************************************************************************************************
!> These specify which array index in the index array is the start of the
!> specified variable. For example, row_p => index(dbcsr_bcsr_slot_row_p).
! **************************************************************************************************
   INTEGER, PARAMETER          :: dbcsr_slot_size = 1 ! Size of the assigned
   ! values in the index
   ! array.
   INTEGER, PARAMETER          :: dbcsr_slot_nblks = 2
   INTEGER, PARAMETER          :: dbcsr_slot_nze = 3
   INTEGER, PARAMETER          :: dbcsr_slot_dense = 4
   INTEGER, PARAMETER          :: dbcsr_slot_nblkrows_total = 5
   INTEGER, PARAMETER          :: dbcsr_slot_nblkcols_total = 6
   INTEGER, PARAMETER          :: dbcsr_slot_nfullrows_total = 7
   INTEGER, PARAMETER          :: dbcsr_slot_nfullcols_total = 8
   INTEGER, PARAMETER          :: dbcsr_slot_nblkrows_local = 9
   INTEGER, PARAMETER          :: dbcsr_slot_nblkcols_local = 10
   INTEGER, PARAMETER          :: dbcsr_slot_nfullrows_local = 11
   INTEGER, PARAMETER          :: dbcsr_slot_nfullcols_local = 12
   INTEGER, PARAMETER          :: dbcsr_slot_type = 13
   INTEGER, PARAMETER          :: dbcsr_slot_home_prow = 14
   INTEGER, PARAMETER          :: dbcsr_slot_home_pcol = 15
   INTEGER, PARAMETER          :: dbcsr_slot_home_rowi = 16
   INTEGER, PARAMETER          :: dbcsr_slot_home_coli = 17
   INTEGER, PARAMETER          :: dbcsr_slot_home_vprow = 18
   INTEGER, PARAMETER          :: dbcsr_slot_home_vpcol = 19
   ! The number of meta fields.  Its value should be the index of the
   ! last slot listed above.
   INTEGER, PARAMETER          :: dbcsr_meta_size = 19
   INTEGER, PARAMETER          :: dbcsr_slot_row_p = dbcsr_meta_size + 2
   INTEGER, PARAMETER          :: dbcsr_slot_col_i = dbcsr_meta_size + 4
   INTEGER, PARAMETER          :: dbcsr_slot_blk_p = dbcsr_meta_size + 6
   INTEGER, PARAMETER          :: dbcsr_slot_thr_c = dbcsr_meta_size + 8
   INTEGER, PARAMETER          :: dbcsr_slot_coo_l = dbcsr_meta_size + 10
   INTEGER, PARAMETER          :: dbcsr_num_slots = dbcsr_meta_size + 11 ! previous + 1

   ! MPI message size limits (in bytes): 128, 8192, 32KB, 128KB, 4MB, 16MB
   INTEGER(KIND=int_8), DIMENSION(6), PARAMETER :: dbcsr_mpi_size_limits = &
                                                   (/2**7, 2**13, 2**15, 2**17, 2**22, 2**24/)

! **************************************************************************************************
!> \brief Pointer to a work matrix.
!> \var w           the work matrix
! **************************************************************************************************
   TYPE dbcsr_work_type_p
      TYPE(dbcsr_work_type), POINTER     :: w => Null()
   END TYPE dbcsr_work_type_p

! **************************************************************************************************
!> \brief Pointer to a object.
!> \var matrix         the dbcsr_typeect
! **************************************************************************************************
   TYPE dbcsr_type_p
      TYPE(dbcsr_type), POINTER           :: matrix => Null()
   END TYPE dbcsr_type_p

! **************************************************************************************************
!> \brief A 1-D array of DBCSR matrices
!> \var s           the array of matrices
! **************************************************************************************************
   TYPE dbcsr_1d_array_obj
      TYPE(dbcsr_type_p), DIMENSION(:), POINTER :: mats => Null()
   END TYPE dbcsr_1d_array_obj

! **************************************************************************************************
!> \brief A 2-D array of DBCSR matrices
!> \var s           the array of matrices
! **************************************************************************************************
   TYPE dbcsr_2d_array_obj
      TYPE(dbcsr_type_p), DIMENSION(:, :), POINTER :: mats => Null()
   END TYPE dbcsr_2d_array_obj

! **************************************************************************************************
!> \brief An array of DBCSR matrices
!> \var mats        the matrices
!> \var data_windows, index_windows     RMA windows
!> \var image_dist  image distribution
! **************************************************************************************************
   TYPE dbcsr_1d_array_type
      TYPE(dbcsr_type), DIMENSION(:), POINTER :: mats => Null()
      TYPE(dbcsr_imagedistribution_obj)      :: image_dist
   END TYPE dbcsr_1d_array_type

! **************************************************************************************************
!> \brief A 2-d array of DBCSR matrices
!> \var mats        the matrices
!> \var image_dist  image distribution
! **************************************************************************************************
   TYPE dbcsr_2d_array_type
      TYPE(dbcsr_type), DIMENSION(:, :), POINTER :: mats => Null()
      TYPE(dbcsr_imagedistribution_obj)         :: image_dist
   END TYPE dbcsr_2d_array_type

! **************************************************************************************************
!> \brief DBCSR MPI statistics
!> \var last_mpi_ranks_used ...
!> \var nimages ...
!> \var nexchanged ...
!> \var nfiltered ...
!> \var data_size ...
!> \var data_size_breakdown ...
! **************************************************************************************************
   TYPE dbcsr_mpi_statistics_type
      INTEGER                                                             :: last_mpi_ranks_used = -1
      INTEGER                                                             :: nimages = -1
      INTEGER                                                             :: nexchanged = -1
      INTEGER                                                             :: nfiltered = -1
      ! rank 1: 1=right, 2=left
      ! rank 2: 1=total, 2=min, 3=max
      REAL, DIMENSION(2, 3)                                               :: data_size = 0.0
      ! message size breakdown
      INTEGER(KIND=int_8), DIMENSION(SIZE(dbcsr_mpi_size_limits) + 1, 2, 2) :: data_size_breakdown = -1
   END TYPE dbcsr_mpi_statistics_type

END MODULE dbcsr_types
